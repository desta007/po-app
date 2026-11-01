<?php

namespace App\Http\Controllers;

use App\Enums\MemberRole;
use App\Http\Requests\Product\StoreProductRequest;
use App\Http\Requests\Product\UpdateProductRequest;
use App\Http\Resources\ProductResource;
use App\Models\Product;
use App\Services\FreeTierLimitService;
use App\Services\PdfExportService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class ProductController extends Controller
{
    public function __construct(
        private FreeTierLimitService $limitService,
        private PdfExportService $pdfService,
    ) {}

    /**
     * Download a PDF catalog of the organization's catalog-visible products.
     * Products are auto-scoped to the authenticated user's organization by the
     * global organization scope, so no explicit org filter is needed here.
     */
    public function exportCatalogPdf(Request $request)
    {
        $org = $request->user()->currentOrganization;

        $products = Product::where('is_active', true)
            ->where('show_in_catalog', true)
            ->orderBy('category')
            ->orderBy('name')
            ->get();

        $filename = 'Katalog-' . \Illuminate\Support\Str::slug($org->name ?: 'produk') . '.pdf';

        return $this->pdfService->generateCatalog($org, $products)->download($filename);
    }

    public function index(Request $request): AnonymousResourceCollection
    {
        // Relasi organization dipakai ProductResource untuk cek Premium (diskon).
        $query = Product::query()->with('organization');

        if ($search = $request->input('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'ilike', "%{$search}%")
                  ->orWhere('sku', 'ilike', "%{$search}%");
            });
        }

        if ($category = $request->input('category')) {
            $query->where('category', $category);
        }

        if ($request->has('is_active')) {
            $query->where('is_active', $request->boolean('is_active'));
        }

        $products = $query->orderBy('name')->paginate($request->input('per_page', 50));

        return ProductResource::collection($products);
    }

    public function store(StoreProductRequest $request): JsonResponse
    {
        $user = $request->user();
        $org = $user->currentOrganization;
        if (!$this->limitService->canBypass($org, $user)) {
            if ($response = $this->limitService->checkProductLimit($user->current_org_id)) {
                return $response;
            }
        }

        if ($response = $this->guardDiscountChange($request, $request->validated())) {
            return $response;
        }

        $product = Product::create($request->validated());

        return response()->json([
            'data' => new ProductResource($product),
            'message' => 'Produk berhasil ditambahkan.',
        ], 201);
    }

    public function show(Product $product): ProductResource
    {
        return new ProductResource($product);
    }

    public function update(UpdateProductRequest $request, Product $product): JsonResponse
    {
        if ($response = $this->guardDiscountChange($request, $request->validated(), $product)) {
            return $response;
        }

        $product->update($request->validated());

        return response()->json([
            'data' => new ProductResource($product),
            'message' => 'Produk berhasil diperbarui.',
        ]);
    }

    /**
     * Diskon produk hanya boleh diubah oleh owner/admin, dan hanya organisasi
     * Premium yang boleh mengaktifkannya. Staff tetap boleh mengedit field lain
     * — klien yang selalu mengirim field diskon tanpa mengubah nilainya lolos.
     */
    private function guardDiscountChange(Request $request, array $data, ?Product $product = null): ?JsonResponse
    {
        $current = [
            'discount_enabled' => (bool) $product?->discount_enabled,
            'discount_type' => $product?->discount_type?->value,
            'discount_value' => (float) $product?->discount_value,
        ];
        $incoming = [
            'discount_enabled' => array_key_exists('discount_enabled', $data) ? (bool) $data['discount_enabled'] : $current['discount_enabled'],
            'discount_type' => array_key_exists('discount_type', $data) ? $data['discount_type'] : $current['discount_type'],
            'discount_value' => array_key_exists('discount_value', $data) ? (float) $data['discount_value'] : $current['discount_value'],
        ];

        // Selama diskon tetap nonaktif, perubahan jenis/nilai tidak berdampak apa pun.
        if ($incoming === $current || (! $incoming['discount_enabled'] && ! $current['discount_enabled'])) {
            return null;
        }

        $user = $request->user();

        if (! $user->is_super_admin) {
            $role = $user->organizationMemberships()
                ->where('organization_id', $user->current_org_id)
                ->value('role');
            $role = $role instanceof MemberRole ? $role : MemberRole::tryFrom((string) $role);

            if (! in_array($role, [MemberRole::OWNER, MemberRole::ADMIN], true)) {
                return response()->json([
                    'message' => 'Hanya owner atau admin yang dapat mengubah diskon produk.',
                ], 403);
            }
        }

        if ($incoming['discount_enabled'] && ! $this->limitService->canBypass($user->currentOrganization, $user)) {
            return $this->limitService->premiumFeatureResponse(
                'Diskon produk hanya tersedia untuk paket Premium. Upgrade ke Premium untuk menggunakan fitur ini.',
                'product_discount',
            );
        }

        return null;
    }

    public function destroy(Product $product): JsonResponse
    {
        $product->delete();

        return response()->json(['message' => 'Produk berhasil dihapus.']);
    }
}
