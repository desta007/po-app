<?php

namespace App\Http\Controllers;

use App\Models\PurchaseOrder;
use App\Models\Customer;
use App\Models\PurchaseOrderItem;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function todaySummary(): JsonResponse
    {
        $orgId = auth()->user()->current_org_id;
        $today = now()->toDateString();
        $yesterday = now()->subDay()->toDateString();
        $thisMonth = now()->startOfMonth()->toDateString();
        $lastMonthStart = now()->subMonth()->startOfMonth()->toDateString();
        $lastMonthEnd = now()->subMonth()->endOfMonth()->toDateString();

        $posToday = PurchaseOrder::where('organization_id', $orgId)
            ->where('delivery_date', $today)
            ->get();
        
        $posYesterdayCount = PurchaseOrder::where('organization_id', $orgId)
            ->where('delivery_date', $yesterday)
            ->count();

        $poTodayCount = $posToday->count();
        $poChange = $posYesterdayCount > 0 ? round((($poTodayCount - $posYesterdayCount) / $posYesterdayCount) * 100) : ($poTodayCount > 0 ? 100 : 0);
        $poChangeUp = $poChange >= 0;

        $revenueThisMonth = PurchaseOrder::where('organization_id', $orgId)
            ->where('status', 'completed')
            ->where('delivery_date', '>=', $thisMonth)
            ->sum('total');

        $revenueLastMonth = PurchaseOrder::where('organization_id', $orgId)
            ->where('status', 'completed')
            ->whereBetween('delivery_date', [$lastMonthStart, $lastMonthEnd])
            ->sum('total');

        $revenueChange = $revenueLastMonth > 0 ? round((($revenueThisMonth - $revenueLastMonth) / $revenueLastMonth) * 100) : ($revenueThisMonth > 0 ? 100 : 0);
        $revenueChangeUp = $revenueChange >= 0;

        $activeCustomers = Customer::where('organization_id', $orgId)->where('total_orders', '>', 0)->count();
        $newCustomersThisMonth = Customer::where('organization_id', $orgId)->where('created_at', '>=', now()->startOfMonth())->count();

        $posThisMonth = PurchaseOrder::where('organization_id', $orgId)
            ->where('delivery_date', '>=', $thisMonth)
            ->get();

        return response()->json([
            'total_po' => $poTodayCount,
            'po_change' => ($poChangeUp ? '↑ ' : '↓ ') . abs($poChange) . '% dari kemarin',
            'po_change_up' => $poChangeUp,
            
            'total_revenue' => (float) $revenueThisMonth,
            'revenue_change' => ($revenueChangeUp ? '↑ ' : '↓ ') . abs($revenueChange) . '% dari bulan lalu',
            'revenue_change_up' => $revenueChangeUp,

            'active_customers' => $activeCustomers,
            'customer_change' => '+' . $newCustomersThisMonth . ' bulan ini',
            'customer_change_up' => true,

            'total_orders_this_month' => $posThisMonth->count(),
            'draft' => $posThisMonth->where('status', 'draft')->count(),
            'confirmed' => $posThisMonth->where('status', 'confirmed')->count(),
            'in_progress' => $posThisMonth->where('status', 'in_progress')->count(),
            'completed' => $posThisMonth->where('status', 'completed')->count(),
        ]);
    }

    public function revenueChart(): JsonResponse
    {
        $orgId = auth()->user()->current_org_id;
        $from = now()->subDays(30)->toDateString();

        $data = PurchaseOrder::where('organization_id', $orgId)
            ->where('status', 'completed')
            ->where('delivery_date', '>=', $from)
            ->select(
                DB::raw("delivery_date as date"),
                DB::raw("SUM(total) as revenue"),
                DB::raw("COUNT(*) as count")
            )
            ->groupBy('delivery_date')
            ->orderBy('delivery_date')
            ->get();

        return response()->json($data);
    }

    public function topCustomers(): JsonResponse
    {
        $orgId = auth()->user()->current_org_id;

        $customers = Customer::where('organization_id', $orgId)
            ->orderByDesc('total_revenue')
            ->limit(5)
            ->get(['id', 'name', 'total_revenue', 'total_orders']);

        return response()->json($customers);
    }

    public function topProducts(): JsonResponse
    {
        $orgId = auth()->user()->current_org_id;
        $from = now()->subDays(30)->toDateString();

        $products = PurchaseOrderItem::join('purchase_orders', 'purchase_order_items.po_id', '=', 'purchase_orders.id')
            ->where('purchase_orders.organization_id', $orgId)
            ->where('purchase_orders.delivery_date', '>=', $from)
            ->where('purchase_orders.status', '!=', 'cancelled')
            ->select(
                'purchase_order_items.product_id as id',
                'purchase_order_items.product_name as name',
                DB::raw("SUM(purchase_order_items.quantity) as total_qty"),
                DB::raw("SUM(purchase_order_items.subtotal) as total_revenue")
            )
            ->groupBy('purchase_order_items.product_id', 'purchase_order_items.product_name')
            ->orderByDesc('total_qty')
            ->limit(5)
            ->get();

        return response()->json($products);
    }

    public function pendingPayments(): JsonResponse
    {
        $orgId = auth()->user()->current_org_id;

        $unpaid = PurchaseOrder::where('organization_id', $orgId)
            ->where('payment_status', 'unpaid')
            ->whereNotIn('status', ['cancelled']);

        $dp = PurchaseOrder::where('organization_id', $orgId)
            ->where('payment_status', 'dp')
            ->whereNotIn('status', ['cancelled']);

        return response()->json([
            'total_unpaid' => $unpaid->count(),
            'total_dp' => $dp->count(),
            'unpaid_amount' => (float) $unpaid->sum('total'),
            'dp_remaining_amount' => (float) $dp->sum(DB::raw('total - dp_amount')),
        ]);
    }
}
