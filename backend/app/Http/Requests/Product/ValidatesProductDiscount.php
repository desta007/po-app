<?php

namespace App\Http\Requests\Product;

use App\Enums\DiscountType;
use App\Models\Product;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Validator;

/**
 * Aturan validasi diskon produk, dipakai bersama Store/UpdateProductRequest.
 *
 * Validasi silang (jenis wajib, persen ≤ 100, nominal ≤ harga) memakai nilai
 * efektif: input request jika dikirim, selain itu nilai produk yang ada — agar
 * update parsial (mis. hanya mengubah harga) tetap tervalidasi dengan benar.
 */
trait ValidatesProductDiscount
{
    public const DISCOUNT_FIELDS = ['discount_enabled', 'discount_type', 'discount_value'];

    protected function discountRules(): array
    {
        return [
            'discount_enabled' => ['nullable', 'boolean'],
            'discount_type' => ['nullable', Rule::enum(DiscountType::class)],
            'discount_value' => ['nullable', 'numeric', 'min:0'],
        ];
    }

    public function after(): array
    {
        return [
            function (Validator $validator) {
                if ($validator->errors()->isNotEmpty()) {
                    return;
                }

                /** @var Product|null $product */
                $product = $this->route('product');

                $enabled = $this->has('discount_enabled')
                    ? $this->boolean('discount_enabled')
                    : (bool) $product?->discount_enabled;

                if (! $enabled) {
                    return;
                }

                $type = $this->has('discount_type')
                    ? $this->input('discount_type')
                    : $product?->discount_type?->value;
                $value = $this->has('discount_value')
                    ? (float) $this->input('discount_value')
                    : (float) $product?->discount_value;
                $price = $this->has('price')
                    ? (float) $this->input('price')
                    : (float) $product?->price;

                if (! $type) {
                    $validator->errors()->add('discount_type', 'Jenis diskon wajib dipilih.');
                } elseif ($value <= 0) {
                    $validator->errors()->add('discount_value', 'Nilai diskon harus lebih dari 0.');
                } elseif ($type === DiscountType::PERCENT->value && $value > 100) {
                    $validator->errors()->add('discount_value', 'Diskon persen maksimal 100%.');
                } elseif ($type === DiscountType::NOMINAL->value && $value > $price) {
                    $validator->errors()->add('discount_value', 'Diskon nominal tidak boleh melebihi harga jual.');
                }
            },
        ];
    }
}
