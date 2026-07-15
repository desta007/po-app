<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        // Legacy fallback: products created before multi-image support only have image_url.
        $images = $this->images ?? [];
        if (empty($images) && $this->image_url) {
            $images = [$this->image_url];
        }

        return [
            'id' => $this->id,
            'organization_id' => $this->organization_id,
            'name' => $this->name,
            'sku' => $this->sku,
            'description' => $this->description,
            'unit' => $this->unit,
            'price' => (float) $this->price,
            'cost' => $this->cost ? (float) $this->cost : null,
            'category' => $this->category,
            'image_url' => $this->image_url,
            'images' => $images,
            'stock_qty' => $this->stock_qty,
            'track_stock' => (bool) $this->track_stock,
            'is_active' => $this->is_active,
            'show_in_catalog' => $this->show_in_catalog,
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
