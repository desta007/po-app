<?php

namespace App\Http\Requests\Product;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProductRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'sku' => ['nullable', 'string', 'max:100'],
            'description' => ['nullable', 'string'],
            'unit' => ['nullable', 'string', 'max:50'],
            'price' => ['sometimes', 'required', 'numeric', 'min:0'],
            'cost' => ['nullable', 'numeric', 'min:0'],
            'category' => ['nullable', 'string', 'max:100'],
            'image_url' => ['nullable', 'string'],
            'stock_qty' => ['nullable', 'integer', 'min:0'],
            'track_stock' => ['nullable', 'boolean'],
            'is_active' => ['nullable', 'boolean'],
            'show_in_catalog' => ['nullable', 'boolean'],
        ];
    }
}
