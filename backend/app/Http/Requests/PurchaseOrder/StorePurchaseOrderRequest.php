<?php

namespace App\Http\Requests\PurchaseOrder;

use Illuminate\Foundation\Http\FormRequest;

class StorePurchaseOrderRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'customer_id' => ['required', 'uuid', 'exists:customers,id'],
            'order_date' => ['nullable', 'date'],
            'delivery_date' => ['required', 'date', 'after_or_equal:today'],
            'discount' => ['nullable', 'numeric', 'min:0'],
            'tax' => ['nullable', 'numeric', 'min:0'],
            'notes' => ['nullable', 'string'],
            'payment_status' => ['nullable', 'in:unpaid,dp,paid'],
            'dp_amount' => ['nullable', 'numeric', 'min:0'],
            'paid_amount' => ['nullable', 'numeric', 'min:0'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['nullable', 'uuid'],
            'items.*.product_name' => ['required', 'string', 'max:255'],
            'items.*.quantity' => ['required', 'numeric', 'min:0.01'],
            'items.*.unit_price' => ['required', 'numeric', 'min:0'],
            'items.*.notes' => ['nullable', 'string'],
        ];
    }

    public function messages(): array
    {
        return [
            'customer_id.required' => 'Pelanggan wajib dipilih.',
            'delivery_date.required' => 'Tanggal pengiriman wajib diisi.',
            'delivery_date.after_or_equal' => 'Tanggal pengiriman tidak boleh di masa lalu.',
            'items.required' => 'Minimal satu item harus ditambahkan.',
            'items.min' => 'Minimal satu item harus ditambahkan.',
            'items.*.product_name.required' => 'Nama produk wajib diisi.',
            'items.*.quantity.required' => 'Jumlah wajib diisi.',
            'items.*.unit_price.required' => 'Harga satuan wajib diisi.',
        ];
    }
}
