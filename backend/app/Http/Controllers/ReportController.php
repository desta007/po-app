<?php

namespace App\Http\Controllers;

use App\Models\PurchaseOrder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReportController extends Controller
{
    public function revenue(Request $request): JsonResponse
    {
        $orgId = auth()->user()->current_org_id;
        $period = $request->input('period', 'daily');
        $from = $request->input('start', now()->subDays(30)->toDateString());
        $to = $request->input('end', now()->toDateString());

        $dateFormat = match ($period) {
            'weekly' => "TO_CHAR(delivery_date, 'IYYY-IW')",
            'monthly' => "TO_CHAR(delivery_date, 'YYYY-MM')",
            default => 'delivery_date',
        };

        $data = PurchaseOrder::where('organization_id', $orgId)
            ->where('status', 'completed')
            ->whereBetween('delivery_date', [$from, $to])
            ->select(
                DB::raw("{$dateFormat} as date"),
                DB::raw("SUM(total) as revenue"),
                DB::raw("COUNT(*) as count")
            )
            ->groupBy(DB::raw($dateFormat))
            ->orderBy(DB::raw($dateFormat))
            ->get();

        return response()->json($data);
    }

    public function exportExcel(Request $request)
    {
        // Placeholder — maatwebsite/excel implementation
        return response()->json(['message' => 'Fitur export Excel akan segera tersedia.'], 501);
    }
}
