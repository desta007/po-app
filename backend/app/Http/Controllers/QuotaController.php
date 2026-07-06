<?php

namespace App\Http\Controllers;

use App\Services\FreeTierLimitService;
use Illuminate\Http\JsonResponse;

class QuotaController extends Controller
{
    public function __construct(
        private FreeTierLimitService $limitService,
    ) {}

    public function usage(): JsonResponse
    {
        $user = auth()->user();
        $org = $user->currentOrganization;

        return response()->json([
            'data' => $this->limitService->getUsageSummary(
                $user->current_org_id,
                $org->isPremium() || $user->is_super_admin
            ),
        ]);
    }
}
