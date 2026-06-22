<?php

namespace App\Http\Controllers;

use App\Models\PurchaseOrder;
use App\Models\PurchaseOrderItem;
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

    public function profitReport(Request $request): JsonResponse
    {
        $orgId = auth()->user()->current_org_id;
        $period = $request->input('period', 'monthly');
        $from = $request->input('start', now()->startOfMonth()->toDateString());
        $to = $request->input('end', now()->toDateString());

        $dateFormat = match ($period) {
            'daily' => 'purchase_orders.delivery_date',
            'weekly' => "TO_CHAR(purchase_orders.delivery_date, 'IYYY-IW')",
            default => "TO_CHAR(purchase_orders.delivery_date, 'YYYY-MM')",
        };

        // Revenue and cost grouped by period
        $data = PurchaseOrderItem::join('purchase_orders', 'purchase_order_items.po_id', '=', 'purchase_orders.id')
            ->leftJoin('products', 'purchase_order_items.product_id', '=', 'products.id')
            ->where('purchase_orders.organization_id', $orgId)
            ->where('purchase_orders.status', 'completed')
            ->whereBetween('purchase_orders.delivery_date', [$from, $to])
            ->select(
                DB::raw("{$dateFormat} as date"),
                DB::raw("SUM(purchase_order_items.subtotal) as revenue"),
                DB::raw("SUM(COALESCE(products.cost, 0) * purchase_order_items.quantity) as total_cost"),
                DB::raw("SUM(purchase_order_items.subtotal) - SUM(COALESCE(products.cost, 0) * purchase_order_items.quantity) as profit"),
                DB::raw("COUNT(DISTINCT purchase_orders.id) as order_count")
            )
            ->groupBy(DB::raw($dateFormat))
            ->orderBy(DB::raw($dateFormat))
            ->get();

        // Summary totals
        $summary = PurchaseOrderItem::join('purchase_orders', 'purchase_order_items.po_id', '=', 'purchase_orders.id')
            ->leftJoin('products', 'purchase_order_items.product_id', '=', 'products.id')
            ->where('purchase_orders.organization_id', $orgId)
            ->where('purchase_orders.status', 'completed')
            ->whereBetween('purchase_orders.delivery_date', [$from, $to])
            ->select(
                DB::raw("SUM(purchase_order_items.subtotal) as total_revenue"),
                DB::raw("SUM(COALESCE(products.cost, 0) * purchase_order_items.quantity) as total_cost"),
                DB::raw("SUM(purchase_order_items.subtotal) - SUM(COALESCE(products.cost, 0) * purchase_order_items.quantity) as total_profit"),
                DB::raw("COUNT(DISTINCT purchase_orders.id) as total_orders")
            )
            ->first();

        // Top profitable products
        $topProducts = PurchaseOrderItem::join('purchase_orders', 'purchase_order_items.po_id', '=', 'purchase_orders.id')
            ->leftJoin('products', 'purchase_order_items.product_id', '=', 'products.id')
            ->where('purchase_orders.organization_id', $orgId)
            ->where('purchase_orders.status', 'completed')
            ->whereBetween('purchase_orders.delivery_date', [$from, $to])
            ->select(
                'purchase_order_items.product_name as name',
                DB::raw("SUM(purchase_order_items.quantity) as total_qty"),
                DB::raw("SUM(purchase_order_items.subtotal) as revenue"),
                DB::raw("SUM(COALESCE(products.cost, 0) * purchase_order_items.quantity) as cost"),
                DB::raw("SUM(purchase_order_items.subtotal) - SUM(COALESCE(products.cost, 0) * purchase_order_items.quantity) as profit")
            )
            ->groupBy('purchase_order_items.product_name')
            ->orderByDesc('profit')
            ->limit(10)
            ->get();

        return response()->json([
            'chart' => $data,
            'summary' => $summary,
            'top_products' => $topProducts,
        ]);
    }

    public function exportExcel(Request $request)
    {
        // Placeholder — maatwebsite/excel implementation
        return response()->json(['message' => 'Fitur export Excel akan segera tersedia.'], 501);
    }
}
