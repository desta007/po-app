<?php

namespace App\Http\Controllers;

use App\Http\Resources\ProductResource;
use App\Models\Customer;
use App\Models\Organization;
use App\Models\Product;
use App\Models\PurchaseOrder;
use App\Models\PurchaseOrderStatusHistory;
use App\Services\NotificationService;
use App\Services\PurchaseOrderNumberGenerator;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PublicCatalogController extends Controller
{
    public function __construct(
        private PurchaseOrderNumberGenerator $numberGenerator,
        private NotificationService $notificationService,
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

        return response()->json([
            'organization' => [
                'name' => $org->name,
                'phone' => $phone,
                'address' => $org->address,
                'logo_url' => $org->logo_url,
            ],
            'products' => ProductResource::collection($products),
            'categories' => $categories,
        ]);
    }

    public function checkout(Request $request, string $slug): JsonResponse
    {
        $request->validate([
            'customer_name' => ['required', 'string', 'max:255'],
            'customer_phone' => ['required', 'string', 'max:20'],
            'customer_address' => ['nullable', 'string'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['nullable', 'uuid'],
            'items.*.product_name' => ['required', 'string', 'max:255'],
            'items.*.quantity' => ['required', 'numeric', 'min:0.01'],
            'items.*.unit_price' => ['required', 'numeric', 'min:0'],
        ]);

        $org = Organization::where('slug', $slug)->firstOrFail();
        $owner = $org->users()->wherePivot('role', 'owner')->first();

        return DB::transaction(function () use ($request, $org, $owner) {
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

            // Calculate totals
            $items = $request->input('items');
            $subtotal = collect($items)->sum(fn ($item) => round($item['quantity'] * $item['unit_price'], 2));

            // Create PO
            $poNumber = $this->numberGenerator->generate($org->id);
            $po = PurchaseOrder::create([
                'organization_id' => $org->id,
                'po_number' => $poNumber,
                'customer_id' => $customer->id,
                'order_date' => now()->toDateString(),
                'delivery_date' => now()->toDateString(),
                'status' => 'draft',
                'payment_status' => 'unpaid',
                'subtotal' => $subtotal,
                'discount' => 0,
                'tax' => 0,
                'shipping_cost' => 0,
                'total' => $subtotal,
                'notes' => 'Pesanan dari katalog online',
                'created_by' => $owner?->id,
            ]);

            // Create PO items
            foreach ($items as $index => $item) {
                $po->items()->create([
                    'product_id' => $item['product_id'] ?? null,
                    'product_name' => $item['product_name'],
                    'quantity' => $item['quantity'],
                    'unit_price' => $item['unit_price'],
                    'subtotal' => round($item['quantity'] * $item['unit_price'], 2),
                    'sort_order' => $index,
                ]);
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
                $totalFormatted = number_format($subtotal, 0, ',', '.');

                $this->notificationService->createInAppNotification(
                    userId: $owner->id,
                    title: "Pesanan baru dari katalog — {$poNumber}",
                    message: "{$customer->name} memesan {$itemCount} produk senilai Rp{$totalFormatted} melalui katalog online.",
                    poId: $po->id,
                    orgId: $org->id,
                );
            }

            return response()->json([
                'message' => 'Pesanan berhasil dibuat.',
                'po_number' => $poNumber,
            ], 201);
        });
    }
}
