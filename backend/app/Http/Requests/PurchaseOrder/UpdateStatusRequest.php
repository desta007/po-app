<?php

namespace App\Http\Requests\PurchaseOrder;

use Illuminate\Foundation\Http\FormRequest;

class UpdateStatusRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'status' => ['required', 'in:draft,confirmed,in_progress,completed,cancelled'],
            'reason' => ['nullable', 'string'],
        ];
    }
}
