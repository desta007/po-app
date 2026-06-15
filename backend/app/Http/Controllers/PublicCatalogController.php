<?php

namespace App\Http\Controllers;

use App\Http\Resources\ProductResource;
use App\Models\Organization;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PublicCatalogController extends Controller
{
    public function show(Request $request, string $slug): JsonResponse
    {
        $org = Organization::where('slug', $slug)->firstOrFail();

        $query = Product::where('organization_id', $org->id)
            ->where('is_active', true);

        if ($search = $request->input('search')) {
            $query->where('name', 'ilike', "%{$search}%");
        }

        if ($category = $request->input('category')) {
            $query->where('category', $category);
        }

        $products = $query->orderBy('category')->orderBy('name')->get();

        $categories = Product::where('organization_id', $org->id)
            ->where('is_active', true)
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
}
