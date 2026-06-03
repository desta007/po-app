<?php

namespace App\Http\Controllers;

use App\Http\Resources\CalendarEventResource;
use App\Models\PurchaseOrder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CalendarController extends Controller
{
    public function events(Request $request)
    {
        $query = PurchaseOrder::with(['customer', 'items']);

        if ($start = $request->input('start')) {
            $query->where('delivery_date', '>=', $start);
        }
        if ($end = $request->input('end')) {
            $query->where('delivery_date', '<=', $end);
        }
        if ($status = $request->input('status')) {
            $query->where('status', $status);
        }
        if ($customerId = $request->input('customer_id')) {
            $query->where('customer_id', $customerId);
        }

        return CalendarEventResource::collection($query->get());
    }

    public function reschedule(Request $request, PurchaseOrder $purchaseOrder): JsonResponse
    {
        $request->validate(['delivery_date' => 'required|date']);

        $purchaseOrder->update(['delivery_date' => $request->delivery_date]);

        return response()->json([
            'data' => new CalendarEventResource($purchaseOrder->load('customer')),
            'message' => 'Tanggal pengiriman berhasil diperbarui.',
        ]);
    }
}
