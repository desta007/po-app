<?php

namespace App\Http\Requests\Product;

use Illuminate\Foundation\Http\FormRequest;

class StoreProductRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    /**
     * Normalise a blank SKU to null so products without a SKU do not collide
     * on the (organization_id, sku) unique index (Postgres treats NULL as
     * distinct, but '' as a concrete value that may only appear once).
     */
    protected function prepareForValidation(): void
    {
        if ($this->has('sku') && trim((string) $this->input('sku')) === '') {
            $this->merge(['sku' => null]);
        }

        // These columns are NOT NULL in the database. Some clients (the mobile
        // app) always include them in the payload even when the form does not
        // manage them, sending an explicit null. Drop the key so the DB default
        // applies on create and the existing value is preserved on update,
        // instead of a null-insert that fails with a 500 "Server Error".
        foreach (['stock_qty', 'track_stock', 'is_active', 'show_in_catalog'] as $key) {
            if ($this->has($key) && $this->input($key) === null) {
                $this->getInputSource()->remove($key);
            }
        }
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'sku' => ['nullable', 'string', 'max:100'],
            'description' => ['nullable', 'string'],
            'unit' => ['nullable', 'string', 'max:50'],
            'price' => ['required', 'numeric', 'min:0'],
            'cost' => ['nullable', 'numeric', 'min:0'],
            'category' => ['nullable', 'string', 'max:100'],
            'image_url' => ['nullable', 'string'],
            'stock_qty' => ['nullable', 'integer', 'min:0'],
            'track_stock' => ['nullable', 'boolean'],
            'is_active' => ['nullable', 'boolean'],
            'show_in_catalog' => ['nullable', 'boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Nama produk wajib diisi.',
            'price.required' => 'Harga wajib diisi.',
            'price.min' => 'Harga tidak boleh negatif.',
        ];
    }
}
