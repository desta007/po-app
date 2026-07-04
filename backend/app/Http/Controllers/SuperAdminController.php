<?php

namespace App\Http\Controllers;

use App\Models\Organization;
use App\Models\PurchaseOrder;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SuperAdminController extends Controller
{
    public function dashboard(): JsonResponse
    {
        $totalUsers = User::where('is_super_admin', false)->count();
        $totalOrgs = Organization::count();
        $totalPOs = PurchaseOrder::count();
        $totalRevenue = PurchaseOrder::where('status', 'completed')->sum('total');

        $newUsersThisMonth = User::where('is_super_admin', false)
            ->where('created_at', '>=', now()->startOfMonth())
            ->count();

        $newOrgsThisMonth = Organization::where('created_at', '>=', now()->startOfMonth())
            ->count();

        $activeUsersToday = User::where('last_login_at', '>=', now()->startOfDay())->count();

        // Monthly growth (last 6 months)
        $monthlyGrowth = collect(range(5, 0))->map(function ($monthsAgo) {
            $start = now()->subMonths($monthsAgo)->startOfMonth();
            $end = now()->subMonths($monthsAgo)->endOfMonth();
            $monthLabel = $start->format('Y-m');

            return [
                'month' => $monthLabel,
                'month_label' => $start->translatedFormat('M Y'),
                'users' => User::where('is_super_admin', false)
                    ->whereBetween('created_at', [$start, $end])->count(),
                'orgs' => Organization::whereBetween('created_at', [$start, $end])->count(),
                'pos' => PurchaseOrder::whereBetween('created_at', [$start, $end])->count(),
                'revenue' => (float) PurchaseOrder::where('status', 'completed')
                    ->whereBetween('created_at', [$start, $end])->sum('total'),
            ];
        })->values();

        // Top 5 organizations by revenue
        $topOrganizations = Organization::select('organizations.id', 'organizations.name')
            ->leftJoin('purchase_orders', function ($join) {
                $join->on('organizations.id', '=', 'purchase_orders.organization_id')
                    ->where('purchase_orders.status', '=', 'completed');
            })
            ->selectRaw('COUNT(purchase_orders.id) as total_pos')
            ->selectRaw('COALESCE(SUM(purchase_orders.total), 0) as total_revenue')
            ->groupBy('organizations.id', 'organizations.name')
            ->orderByDesc('total_revenue')
            ->limit(5)
            ->get();

        return response()->json([
            'total_users' => $totalUsers,
            'total_organizations' => $totalOrgs,
            'total_purchase_orders' => $totalPOs,
            'total_revenue' => (float) $totalRevenue,
            'new_users_this_month' => $newUsersThisMonth,
            'new_orgs_this_month' => $newOrgsThisMonth,
            'active_users_today' => $activeUsersToday,
            'monthly_growth' => $monthlyGrowth,
            'top_organizations' => $topOrganizations,
        ]);
    }

    public function users(Request $request): JsonResponse
    {
        $query = User::where('is_super_admin', false)
            ->with(['currentOrganization:id,name', 'organizationMemberships' => function ($q) {
                $q->select('id', 'user_id', 'organization_id', 'role');
            }]);

        if ($search = $request->input('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'ilike', "%{$search}%")
                  ->orWhere('full_name', 'ilike', "%{$search}%")
                  ->orWhere('email', 'ilike', "%{$search}%");
            });
        }

        $users = $query->orderByDesc('created_at')
            ->paginate($request->input('per_page', 20));

        $users->getCollection()->transform(function ($user) {
            $currentMembership = $user->organizationMemberships
                ->where('organization_id', $user->current_org_id)
                ->first();

            return [
                'id' => $user->id,
                'name' => $user->full_name ?? $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'organization' => $user->currentOrganization?->name,
                'role' => $currentMembership?->role?->value,
                'is_active' => (bool) $user->is_active,
                'last_login_at' => $user->last_login_at,
                'created_at' => $user->created_at,
            ];
        });

        return response()->json($users);
    }

    public function userDetail(int $id): JsonResponse
    {
        $user = User::with(['organizationMemberships.organization:id,name'])
            ->findOrFail($id);

        return response()->json([
            'data' => [
                'id' => $user->id,
                'name' => $user->full_name ?? $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'avatar_url' => $user->avatar_url,
                'is_super_admin' => (bool) $user->is_super_admin,
                'last_login_at' => $user->last_login_at,
                'created_at' => $user->created_at,
                'memberships' => $user->organizationMemberships->map(fn ($m) => [
                    'organization_id' => $m->organization_id,
                    'organization_name' => $m->organization->name,
                    'role' => $m->role->value,
                    'joined_at' => $m->joined_at,
                ]),
            ],
        ]);
    }

    public function toggleUserStatus(int $id): JsonResponse
    {
        $user = User::where('is_super_admin', false)->findOrFail($id);

        $user->update(['is_active' => !$user->is_active]);

        // Revoke all tokens when deactivating user
        if (!$user->is_active) {
            $user->tokens()->delete();
        }

        return response()->json([
            'message' => $user->is_active
                ? 'User berhasil diaktifkan.'
                : 'User berhasil dinonaktifkan.',
            'is_active' => (bool) $user->is_active,
        ]);
    }

    public function organizations(Request $request): JsonResponse
    {
        $query = Organization::withCount('members')
            ->withCount('purchaseOrders');

        if ($search = $request->input('search')) {
            $query->where('name', 'ilike', "%{$search}%");
        }

        $organizations = $query->orderByDesc('created_at')
            ->paginate($request->input('per_page', 20));

        $organizations->getCollection()->transform(function ($org) {
            // Get owner
            $owner = $org->members()->where('role', 'owner')->with('user:id,full_name,name,email')->first();

            // Get total revenue
            $totalRevenue = $org->purchaseOrders()->where('status', 'completed')->sum('total');

            return [
                'id' => $org->id,
                'name' => $org->name,
                'slug' => $org->slug,
                'phone' => $org->phone,
                'owner_name' => $owner ? ($owner->user->full_name ?? $owner->user->name) : '-',
                'owner_email' => $owner?->user->email,
                'members_count' => $org->members_count,
                'purchase_orders_count' => $org->purchase_orders_count,
                'total_revenue' => (float) $totalRevenue,
                'created_at' => $org->created_at,
            ];
        });

        return response()->json($organizations);
    }
}
