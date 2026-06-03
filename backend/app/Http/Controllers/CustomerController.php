<?php

namespace App\Http\Controllers;

use App\Http\Requests\Customer\StoreCustomerRequest;
use App\Http\Requests\Customer\UpdateCustomerRequest;
use App\Http\Resources\CustomerResource;
use App\Models\Customer;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class CustomerController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = Customer::query();

        if ($search = $request->input('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'ilike', "%{$search}%")
                  ->orWhere('phone', 'ilike', "%{$search}%")
                  ->orWhere('email', 'ilike', "%{$search}%");
            });
        }

        $customers = $query->orderBy('name')->paginate($request->input('per_page', 15));

        return CustomerResource::collection($customers);
    }

    public function store(StoreCustomerRequest $request): JsonResponse
    {
        $customer = Customer::create($request->validated());

        return response()->json([
            'data' => new CustomerResource($customer),
            'message' => 'Pelanggan berhasil ditambahkan.',
        ], 201);
    }

    public function show(Customer $customer): CustomerResource
    {
        $customer->load(['purchaseOrders' => function ($q) {
            $q->latest()->limit(10);
        }]);

        return new CustomerResource($customer);
    }

    public function update(UpdateCustomerRequest $request, Customer $customer): JsonResponse
    {
        $customer->update($request->validated());

        return response()->json([
            'data' => new CustomerResource($customer),
            'message' => 'Data pelanggan berhasil diperbarui.',
        ]);
    }

    public function destroy(Customer $customer): JsonResponse
    {
        $customer->delete(); // soft delete

        return response()->json(['message' => 'Pelanggan berhasil dihapus.']);
    }
}
