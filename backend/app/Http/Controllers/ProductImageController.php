<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProductImageController extends Controller
{
    /**
     * Upload one or more images for a product.
     * Accepts `images[]` (multiple) and/or a single `image` for backward compatibility.
     * Uploaded images are appended to the product's existing gallery.
     */
    public function store(Request $request, Product $product): JsonResponse
    {
        $request->validate([
            'images' => ['sometimes', 'array', 'max:10'],
            'images.*' => ['image', 'mimes:jpg,jpeg,png,webp', 'max:3072'],
            'image' => ['sometimes', 'image', 'mimes:jpg,jpeg,png,webp', 'max:3072'],
        ]);

        $files = $request->file('images', []);
        if ($request->hasFile('image')) {
            $files[] = $request->file('image');
        }

        if (empty($files)) {
            return response()->json(['message' => 'Tidak ada gambar untuk diupload.'], 422);
        }

        // Start from the existing gallery; seed with legacy image_url if gallery is empty.
        $images = $product->images ?? [];
        if (empty($images) && $product->image_url) {
            $images = [$product->image_url];
        }

        foreach ($files as $file) {
            $path = $file->store('products', 'public');
            $images[] = '/storage/' . $path;
        }

        $product->update([
            'images' => $images,
            'image_url' => $images[0], // first image is the cover
        ]);

        return response()->json([
            'data' => [
                'image_url' => $product->image_url,
                'images' => $product->images,
            ],
            'message' => 'Gambar produk berhasil diupload.',
        ]);
    }

    /**
     * Delete a specific image (via `image_url` in the request body) or all images
     * when no target is provided.
     */
    public function destroy(Request $request, Product $product): JsonResponse
    {
        $target = $request->input('image_url');

        // Existing gallery, seeded with legacy image_url when empty.
        $images = $product->images ?? [];
        if (empty($images) && $product->image_url) {
            $images = [$product->image_url];
        }

        if ($target) {
            // Delete a single image from the gallery.
            $images = array_values(array_filter($images, fn ($img) => $img !== $target));
            Storage::disk('public')->delete(str_replace('/storage/', '', $target));

            $product->update([
                'images' => $images,
                // Promote the next image to cover if the cover was removed.
                'image_url' => $product->image_url === $target ? ($images[0] ?? null) : $product->image_url,
            ]);
        } else {
            // Delete the entire gallery.
            foreach ($images as $img) {
                Storage::disk('public')->delete(str_replace('/storage/', '', $img));
            }

            $product->update([
                'images' => [],
                'image_url' => null,
            ]);
        }

        return response()->json([
            'data' => [
                'image_url' => $product->image_url,
                'images' => $product->images,
            ],
            'message' => 'Gambar produk berhasil dihapus.',
        ]);
    }
}
