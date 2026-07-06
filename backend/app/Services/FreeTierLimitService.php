<?php

namespace App\Services;

use App\Models\Organization;
use App\Models\OrganizationMember;
use App\Models\Product;
use App\Models\PurchaseOrder;
use Illuminate\Http\JsonResponse;

class FreeTierLimitService
{
    const PO_MONTHLY_LIMIT = 20;
    const PRODUCT_LIMIT = 10;
    const TEAM_MEMBER_LIMIT = 2;

    public function canBypass(?Organization $org, $user = null): bool
    {
        if ($user?->is_super_admin) return true;
        if ($org?->isPremium()) return true;
        return false;
    }

    public function getMonthlyPoCount(string $orgId): int
    {
        return PurchaseOrder::withoutGlobalScopes()
            ->where('organization_id', $orgId)
            ->whereYear('created_at', now()->year)
            ->whereMonth('created_at', now()->month)
            ->count();
    }

    public function checkPoLimit(string $orgId): ?JsonResponse
    {
        $current = $this->getMonthlyPoCount($orgId);
        if ($current >= self::PO_MONTHLY_LIMIT) {
            return $this->limitExceededResponse(
                'Batas pembuatan PO bulan ini telah tercapai (' . self::PO_MONTHLY_LIMIT . ' PO/bulan). Upgrade ke Premium untuk PO tanpa batas.',
                'po_monthly',
                $current,
                self::PO_MONTHLY_LIMIT
            );
        }
        return null;
    }

    public function getProductCount(string $orgId): int
    {
        return Product::withoutGlobalScopes()
            ->where('organization_id', $orgId)
            ->count();
    }

    public function checkProductLimit(string $orgId): ?JsonResponse
    {
        $current = $this->getProductCount($orgId);
        if ($current >= self::PRODUCT_LIMIT) {
            return $this->limitExceededResponse(
                'Batas jumlah produk telah tercapai (' . self::PRODUCT_LIMIT . ' produk). Upgrade ke Premium untuk produk tanpa batas.',
                'products',
                $current,
                self::PRODUCT_LIMIT
            );
        }
        return null;
    }

    public function getTeamMemberCount(string $orgId): int
    {
        return OrganizationMember::where('organization_id', $orgId)->count();
    }

    public function checkTeamMemberLimit(string $orgId): ?JsonResponse
    {
        $current = $this->getTeamMemberCount($orgId);
        if ($current >= self::TEAM_MEMBER_LIMIT) {
            return $this->limitExceededResponse(
                'Batas jumlah anggota tim telah tercapai (' . self::TEAM_MEMBER_LIMIT . ' anggota). Upgrade ke Premium untuk menambah lebih banyak anggota.',
                'team_members',
                $current,
                self::TEAM_MEMBER_LIMIT
            );
        }
        return null;
    }

    public function getUsageSummary(string $orgId, bool $isPremium): array
    {
        return [
            'is_premium' => $isPremium,
            'po_monthly' => [
                'current' => $this->getMonthlyPoCount($orgId),
                'limit' => $isPremium ? null : self::PO_MONTHLY_LIMIT,
            ],
            'products' => [
                'current' => $this->getProductCount($orgId),
                'limit' => $isPremium ? null : self::PRODUCT_LIMIT,
            ],
            'team_members' => [
                'current' => $this->getTeamMemberCount($orgId),
                'limit' => $isPremium ? null : self::TEAM_MEMBER_LIMIT,
            ],
        ];
    }

    private function limitExceededResponse(string $message, string $resource, int $current, int $limit): JsonResponse
    {
        return response()->json([
            'message' => $message,
            'upgrade_required' => true,
            'resource' => $resource,
            'usage' => [
                'current' => $current,
                'limit' => $limit,
            ],
        ], 403);
    }
}
