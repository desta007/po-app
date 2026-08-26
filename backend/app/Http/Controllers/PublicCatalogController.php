<?php

namespace App\Http\Controllers;

use App\Http\Concerns\VerifiesCustomerPhone;
use App\Http\Resources\ProductResource;
use App\Jobs\SendWhatsAppNotification;
use App\Models\Customer;
use App\Models\Organization;
use App\Models\Product;
use App\Models\PurchaseOrder;
use App\Models\PurchaseOrderStatusHistory;
use App\Services\NotificationService;
use App\Services\PurchaseOrderNumberGenerator;
use App\Services\StockService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class PublicCatalogController extends Controller
{
    use VerifiesCustomerPhone;

    public function __construct(
        private PurchaseOrderNumberGenerator $numberGenerator,
        private NotificationService $notificationService,
        private StockService $stockService,
    ) {}

    public function show(Request $request, string $slug): JsonResponse
    {
        $org = Organization::where('slug', $slug)->firstOrFail();

        $query = Product::where('organization_id', $org->id)
            ->where('is_active', true)
            ->where('show_in_catalog', true);

        if ($search = $request->input('search')) {
            $query->where('name', 'ilike', "%{$search}%");
        }

        if ($category = $request->input('category')) {
            $query->where('category', $category);
        }

        $products = $query->orderBy('category')->orderBy('name')->get();

        $categories = Product::where('organization_id', $org->id)
            ->where('is_active', true)
            ->where('show_in_catalog', true)
            ->whereNotNull('category')
            ->distinct()
            ->pluck('category')
            ->sort()
            ->values();

        $owner = $org->users()->wherePivot('role', 'owner')->first();
        $phone = $org->phone ?: $owner?->phone;

        $shipping = $org->onlineStore()['shipping'] ?? [];

        return response()->json([
            'organization' => [
                'name' => $org->name,
                'phone' => $phone,
                'address' => $org->address,
                'logo_url' => $org->logo_url,
            ],
            'products' => ProductResource::collection($products),
            'categories' => $categories,
            'store' => [
                'online_payment_available' => $org->isOnlinePaymentEnabled(),
                'shipping' => [
                    'flat_rates' => array_values(array_map(fn ($r) => [
                        'name' => $r['name'] ?? '',
                        'cost' => (float) ($r['cost'] ?? 0),
                    ], $shipping['flat_rates'] ?? [])),
                    'allow_pickup' => (bool) ($shipping['allow_pickup'] ?? false),
                    'allow_shipping_tbd' => (bool) ($shipping['allow_shipping_tbd'] ?? false),
                ],
            ],
        ]);
    }

    public function checkout(Request $request, string $slug): JsonResponse
    {
        $request->validate([
            'customer_name' => ['required', 'string', 'max:255'],
            'customer_phone' => ['required', 'string', 'max:20'],
            'customer_address' => ['nullable', 'string'],
            'items' => ['required', 'array', 'min:1', 'max:100'],
            'items.*.product_id' => ['required', 'uuid'],
            'items.*.quantity' => ['required', 'numeric', 'min:0.01', 'max:100000'],
            'shipping_method' => ['nullable', 'string', 'max:100'],
            'payment_preference' => ['nullable', 'in:online,whatsapp'],
            'delivery_date' => ['nullable', 'date', 'after_or_equal:today'],
        ]);

        $org = Organization::where('slug', $slug)->firstOrFail();
        $owner = $org->users()->wherePivot('role', 'owner')->first();

        // Shipping cost is derived from the store's own config, never trusted from the client.
        [$shippingCost, $shippingLabel] = $this->resolveShipping($org, $request->input('shipping_method'));

        [$po, $customer, $lineItems, $total] = DB::transaction(function () use ($request, $org, $owner, $shippingCost, $shippingLabel) {
            $items = $request->input('items');

            // Load only products that genuinely belong to this store's public catalog.
            // Price and name are taken from these records, never from the request body,
            // so a manipulated unit_price/product_name in the payload has no effect.
            $productIds = collect($items)->pluck('product_id')->unique();
            $products = Product::where('organization_id', $org->id)
                ->where('is_active', true)
                ->where('show_in_catalog', true)
                ->whereIn('id', $productIds)
                ->lockForUpdate()
                ->get()
                ->keyBy('id');

            // Total quantity per product (guards against the same product on multiple lines).
            $quantities = [];
            foreach ($items as $item) {
                $pid = $item['product_id'];
                $quantities[$pid] = ($quantities[$pid] ?? 0) + $item['quantity'];
            }

            $errors = [];
            foreach ($quantities as $pid => $qty) {
                $product = $products->get($pid);
                if (! $product) {
                    $errors[] = 'Salah satu produk tidak tersedia atau tidak dijual di katalog ini.';
                    continue;
                }
                if ($qty > $product->stock_qty) {
                    $errors[] = "Stok \"{$product->name}\" tidak mencukupi (tersisa {$product->stock_qty}).";
                }
            }

            if (! empty($errors)) {
                throw ValidationException::withMessages([
                    'items' => array_values(array_unique($errors)),
                ]);
            }

            // Reserve stock now (order creation), honoring per-product track_stock.
            $this->stockService->decrement($quantities, $products);

            // Find or create customer by phone
            $phone = $request->input('customer_phone');
            $customer = Customer::where('organization_id', $org->id)
                ->where('phone', $phone)
                ->first();

            if ($customer) {
                $customer->update([
                    'name' => $request->input('customer_name'),
                    'address' => $request->input('customer_address'),
                ]);
            } else {
                $customer = Customer::create([
                    'organization_id' => $org->id,
                    'name' => $request->input('customer_name'),
                    'phone' => $phone,
                    'address' => $request->input('customer_address'),
                ]);
            }

            // Build server-authoritative line items using prices from the database.
            $subtotal = 0;
            $lineItems = [];
            foreach ($items as $index => $item) {
                $product = $products->get($item['product_id']);
                $quantity = $item['quantity'];
                $unitPrice = $product->price;
                $lineSubtotal = round($quantity * $unitPrice, 2);
                $subtotal += $lineSubtotal;

                $lineItems[] = [
                    'product_id' => $product->id,
                    'product_name' => $product->name,
                    'quantity' => $quantity,
                    'unit_price' => $unitPrice,
                    'subtotal' => $lineSubtotal,
                    'sort_order' => $index,
                ];
            }

            $total = round($subtotal + $shippingCost, 2);
            $notes = 'Pesanan dari katalog online';
            if ($shippingLabel) {
                $notes .= " · Pengiriman: {$shippingLabel}";
            }

            // Create PO
            $poNumber = $this->numberGenerator->generate($org->id);
            $po = PurchaseOrder::create([
                'organization_id' => $org->id,
                'po_number' => $poNumber,
                'customer_id' => $customer->id,
                'order_date' => now()->toDateString(),
                'delivery_date' => $request->input('delivery_date') ?: now()->toDateString(),
                'status' => 'draft',
                'source' => 'catalog',
                'payment_status' => 'unpaid',
                'subtotal' => $subtotal,
                'discount' => 0,
                'tax' => 0,
                'shipping_cost' => $shippingCost,
                'shipping_method' => $shippingLabel,
                'total' => $total,
                'notes' => $notes,
                'created_by' => $owner?->id,
            ]);

            // Create PO items
            foreach ($lineItems as $lineItem) {
                $po->items()->create($lineItem);
            }

            // Log status history
            PurchaseOrderStatusHistory::create([
                'po_id' => $po->id,
                'from_status' => null,
                'to_status' => 'draft',
                'changed_by' => $owner?->id,
                'changed_at' => now(),
            ]);

            // Send in-app notification to the org owner
            if ($owner) {
                $itemCount = count($items);
                $totalFormatted = number_format($total, 0, ',', '.');

                $this->notificationService->createInAppNotification(
                    userId: $owner->id,
                    title: "Pesanan baru dari katalog — {$poNumber}",
                    message: "{$customer->name} memesan {$itemCount} produk senilai Rp{$totalFormatted} melalui katalog online.",
                    poId: $po->id,
                    orgId: $org->id,
                );
            }

            return [$po, $customer, $lineItems, $total];
        });

        // Fire-and-forget WhatsApp messages. Dispatched only after the transaction
        // has committed (we're outside DB::transaction now), so a rolled-back order
        // never triggers a send, and a WhatsApp/queue failure never fails checkout.
        $sellerPhone = $org->phone ?: $owner?->phone;
        if ($sellerPhone) {
            SendWhatsAppNotification::dispatch(
                $sellerPhone,
                $this->buildSellerMessage($org, $po, $customer, $lineItems, $shippingLabel, $shippingCost, $total),
            );
        }

        if ($customer->phone) {
            SendWhatsAppNotification::dispatch(
                $customer->phone,
                $this->buildCustomerMessage($org, $po, $customer, $lineItems, $shippingLabel, $shippingCost, $total),
            );
        }

        return response()->json([
            'message' => 'Pesanan berhasil dibuat.',
            'po_number' => $po->po_number,
            'total' => $total,
            'shipping_cost' => $shippingCost,
            'online_payment_available' => $org->isOnlinePaymentEnabled(),
        ], 201);
    }

    /**
     * WhatsApp message sent to the store owner when a catalog order comes in.
     *
     * @param  array<int, array<string, mixed>>  $lineItems
     */
    private function buildSellerMessage(Organization $org, PurchaseOrder $po, Customer $customer, array $lineItems, ?string $shippingLabel, float $shippingCost, float $total): string
    {
        $text = "🛒 *Pesanan Baru dari Katalog*\n";
        $text .= "No. PO: *{$po->po_number}*\n\n";
        $text .= "*Data Pemesan*\n";
        $text .= "Nama: {$customer->name}\n";
        $text .= "No. HP: {$customer->phone}\n";
        if ($customer->address) {
            $text .= "Alamat: {$customer->address}\n";
        }
        $text .= "Tanggal: " . $this->formatDate($po->delivery_date) . "\n\n";
        $text .= $this->formatItemLines($lineItems, $shippingLabel, $shippingCost, $total);
        $text .= "\n\nBuka aplikasi untuk memproses pesanan ini.";

        return $text;
    }

    /**
     * WhatsApp confirmation sent to the customer after checkout.
     *
     * @param  array<int, array<string, mixed>>  $lineItems
     */
    private function buildCustomerMessage(Organization $org, PurchaseOrder $po, Customer $customer, array $lineItems, ?string $shippingLabel, float $shippingCost, float $total): string
    {
        $text = "Halo {$customer->name}, terima kasih telah memesan di *{$org->name}*! 🙏\n\n";
        $text .= "Pesanan Anda sudah kami terima.\n";
        $text .= "No. PO: *{$po->po_number}*\n";
        $text .= "Tanggal: " . $this->formatDate($po->delivery_date) . "\n\n";
        $text .= $this->formatItemLines($lineItems, $shippingLabel, $shippingCost, $total);

        $statusUrl = rtrim((string) config('app.frontend_url'), '/')
            . "/katalog/{$org->slug}/pesanan/" . rawurlencode($po->po_number);
        $text .= "\n\nCek status pesanan Anda di:\n{$statusUrl}";
        $text .= "\n\nKami akan segera mengonfirmasi ketersediaan & pembayaran. Terima kasih!";

        return $text;
    }

    /**
     * Shared "*Detail Pesanan*" block used in both seller and customer messages.
     *
     * @param  array<int, array<string, mixed>>  $lineItems
     */
    private function formatItemLines(array $lineItems, ?string $shippingLabel, float $shippingCost, float $total): string
    {
        $text = "*Detail Pesanan*\n";
        foreach ($lineItems as $i => $item) {
            $lineTotal = 'Rp' . number_format((float) $item['subtotal'], 0, ',', '.');
            $qty = rtrim(rtrim(number_format((float) $item['quantity'], 2, '.', ''), '0'), '.');
            $text .= ($i + 1) . ". {$item['product_name']} (x{$qty}) - {$lineTotal}\n";
        }
        if ($shippingLabel) {
            $text .= "Pengiriman: {$shippingLabel}";
            $text .= $shippingCost > 0 ? ' (Rp' . number_format($shippingCost, 0, ',', '.') . ')' : '';
            $text .= "\n";
        }
        $text .= "Total: *Rp" . number_format($total, 0, ',', '.') . "*";

        return $text;
    }

    private function formatDate(mixed $date): string
    {
        try {
            return \Illuminate\Support\Carbon::parse($date)->format('d M Y');
        } catch (\Throwable) {
            return (string) $date;
        }
    }

    /**
     * Resolve the authoritative shipping cost + human label from the store's config.
     *
     * @return array{0: float, 1: string|null}
     */
    private function resolveShipping(Organization $org, ?string $method): array
    {
        if (! $method) {
            return [0.0, null];
        }

        $shipping = $org->onlineStore()['shipping'] ?? [];

        $flatRates = $shipping['flat_rates'] ?? [];
        $allowPickup = (bool) ($shipping['allow_pickup'] ?? false);
        $allowTbd = (bool) ($shipping['allow_shipping_tbd'] ?? false);

        // When the store has configured no fulfillment method at all, the checkout
        // still offers pickup + "ongkir dihitung kemudian" as a baseline, so accept
        // those here too (both are zero-cost — no way to underpay a flat rate).
        $noConfig = empty($flatRates) && ! $allowPickup && ! $allowTbd;

        if ($method === 'pickup' && ($allowPickup || $noConfig)) {
            return [0.0, 'Ambil di Tempat'];
        }

        if ($method === 'tbd' && ($allowTbd || $noConfig)) {
            return [0.0, 'Ongkir dihitung kemudian'];
        }

        foreach ($shipping['flat_rates'] ?? [] as $rate) {
            if (($rate['name'] ?? null) === $method) {
                return [round((float) ($rate['cost'] ?? 0), 2), $rate['name']];
            }
        }

        // Unknown method → no shipping charge, no label (defensive default).
        return [0.0, null];
    }

    /**
     * Public order-listing endpoint. Returns every catalog order placed with a
     * given WhatsApp number so a customer can track their orders without having
     * to remember a specific PO number. The phone is the only key: it is not
     * enumerable the way sequential PO numbers are.
     */
    public function orderList(Request $request, string $slug): JsonResponse
    {
        $request->validate(['phone' => ['required', 'string', 'max:20']]);

        $org = Organization::where('slug', $slug)->firstOrFail();

        $canonical = $this->normalizePhone($request->input('phone'));
        if ($canonical === '') {
            return response()->json(['data' => [], 'organization' => ['name' => $org->name]]);
        }

        // Narrow candidates by the last significant digits at the DB level, then
        // verify each precisely (handles the 0/62 prefix and stray formatting).
        $suffix = substr($canonical, -8);
        $customerIds = Customer::where('organization_id', $org->id)
            ->where('phone', 'like', "%{$suffix}%")
            ->get()
            ->filter(fn (Customer $c) => $this->phonesMatch($request->input('phone'), $c->phone))
            ->pluck('id');

        if ($customerIds->isEmpty()) {
            return response()->json(['data' => [], 'organization' => ['name' => $org->name]]);
        }

        $orders = PurchaseOrder::where('organization_id', $org->id)
            ->whereIn('customer_id', $customerIds)
            ->where('source', 'catalog')
            ->orderByDesc('created_at')
            ->limit(50)
            ->get();

        return response()->json([
            'data' => $orders->map(fn (PurchaseOrder $po) => [
                'po_number' => $po->po_number,
                'status' => $po->status->value,
                'status_label' => $po->status->label(),
                'payment_status' => $po->payment_status->value,
                'payment_status_label' => $po->payment_status->label(),
                'total' => (float) $po->total,
                'created_at' => $po->created_at,
            ]),
            'organization' => ['name' => $org->name],
        ]);
    }

    /**
     * Public order-tracking endpoint. Requires the matching customer phone to
     * prevent order enumeration.
     */
    public function orderStatus(Request $request, string $slug, string $poNumber): JsonResponse
    {
        $request->validate(['phone' => ['required', 'string', 'max:20']]);

        $org = Organization::where('slug', $slug)->firstOrFail();
        $po = PurchaseOrder::where('organization_id', $org->id)
            ->where('po_number', $poNumber)
            ->with(['customer', 'items'])
            ->firstOrFail();

        if (! $this->phonesMatch($request->input('phone'), $po->customer?->phone)) {
            return response()->json(['message' => 'Nomor HP tidak cocok dengan pesanan ini.'], 403);
        }

        return response()->json([
            'data' => [
                'po_number' => $po->po_number,
                'status' => $po->status->value,
                'status_label' => $po->status->label(),
                'payment_status' => $po->payment_status->value,
                'payment_status_label' => $po->payment_status->label(),
                'subtotal' => (float) $po->subtotal,
                'shipping_cost' => (float) $po->shipping_cost,
                'shipping_method' => $po->shipping_method,
                'tracking_number' => $po->tracking_number,
                'total' => (float) $po->total,
                'notes' => $po->notes,
                'created_at' => $po->created_at,
                'customer_name' => $po->customer?->name,
                'items' => $po->items->map(fn ($item) => [
                    'product_name' => $item->product_name,
                    'quantity' => (float) $item->quantity,
                    'unit_price' => (float) $item->unit_price,
                    'subtotal' => (float) $item->subtotal,
                ]),
                'organization' => ['name' => $org->name, 'phone' => $org->phone],
                'online_payment_available' => $org->isOnlinePaymentEnabled(),
            ],
        ]);
    }
}
