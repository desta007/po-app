<?php

namespace App\Services;

use App\Models\Product;
use App\Models\PurchaseOrder;

class StockService
{
    /**
     * Decrement stock for a set of ordered products.
     * Only products flagged track_stock are affected.
     *
     * @param array<string, float> $quantities  productId => quantity
     * @param \Illuminate\Support\Collection<string, Product> $products  already-locked products keyed by id
     */
    public function decrement(array $quantities, $products): void
    {
        foreach ($quantities as $productId => $qty) {
            $product = $products->get($productId);
            if ($product && $product->track_stock) {
                $product->decrement('stock_qty', (int) round($qty));
            }
        }
    }

    /**
     * Restore stock for every tracked item of an order (used on cancellation of
     * orders that previously reserved stock, e.g. catalog orders).
     */
    public function restoreForOrder(PurchaseOrder $po): void
    {
        $po->loadMissing('items');

        $productIds = $po->items->pluck('product_id')->filter()->unique();
        if ($productIds->isEmpty()) {
            return;
        }

        $products = Product::whereIn('id', $productIds)->lockForUpdate()->get()->keyBy('id');

        foreach ($po->items as $item) {
            if (! $item->product_id) {
                continue;
            }
            $product = $products->get($item->product_id);
            if ($product && $product->track_stock) {
                $product->increment('stock_qty', (int) round($item->quantity));
            }
        }
    }
}
