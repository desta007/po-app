<?php

namespace App\Http\Requests\Customer;

use Illuminate\Foundation\Http\FormRequest;

class StoreCustomerRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    /**
     * The `tags` column is NOT NULL (default '[]'). The mobile app always
     * includes `tags` in the payload even when the form does not manage it,
     * sending an explicit null. Drop the key so the DB default applies instead
     * of a null-insert that fails with a 500 "Server Error".
     */
    protected function prepareForValidation(): void
    {
        if ($this->has('tags') && $this->input('tags') === null) {
            $this->getInputSource()->remove('tags');
        }
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:20'],
            'email' => ['nullable', 'email', 'max:255'],
            'address' => ['nullable', 'string'],
            'notes' => ['nullable', 'string'],
            'tags' => ['nullable', 'array'],
            'tags.*' => ['string'],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Nama pelanggan wajib diisi.',
        ];
    }
}
