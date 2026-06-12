<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProductImageController extends Controller
{
    public function store(Request $request, Product $product): JsonResponse
    {
        $request->validate([
            'image' => ['required', 'image', 'mimes:jpg,jpeg,png,webp', 'max:2048'],
        ]);

        // Delete old image if exists
        if ($product->image_url) {
            $oldPath = str_replace('/storage/', '', $product->image_url);
            Storage::disk('public')->delete($oldPath);
        }

        $path = $request->file('image')->store('products', 'public');
        $product->update(['image_url' => '/storage/' . $path]);

        return response()->json([
            'data' => ['image_url' => $product->image_url],
            'message' => 'Gambar produk berhasil diupload.',
        ]);
    }

    public function destroy(Product $product): JsonResponse
    {
        if ($product->image_url) {
            $path = str_replace('/storage/', '', $product->image_url);
            Storage::disk('public')->delete($path);
            $product->update(['image_url' => null]);
        }

        return response()->json(['message' => 'Gambar produk berhasil dihapus.']);
    }
}
