<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureOrganizationAccess
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (!$user || !$user->current_org_id) {
            return response()->json([
                'message' => 'Anda belum memiliki organisasi. Silakan buat organisasi terlebih dahulu.',
            ], 403);
        }

        // Verify user is actually a member of the current org
        $isMember = $user->organizationMemberships()
            ->where('organization_id', $user->current_org_id)
            ->exists();

        if (!$isMember) {
            return response()->json([
                'message' => 'Anda tidak memiliki akses ke organisasi ini.',
            ], 403);
        }

        return $next($request);
    }
}
