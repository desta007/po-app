<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckRole
{
    /**
     * Handle an incoming request.
     * Usage: middleware('role:owner,admin')
     *
     * @param string $roles Comma-separated list of allowed roles
     */
    public function handle(Request $request, Closure $next, string $roles): Response
    {
        $user = $request->user();

        if (!$user || !$user->current_org_id) {
            return response()->json([
                'message' => 'Anda belum memiliki organisasi.',
            ], 403);
        }

        // Super admin bypasses role checks
        if ($user->is_super_admin) {
            return $next($request);
        }

        $allowedRoles = explode(',', $roles);

        $membership = $user->organizationMemberships()
            ->where('organization_id', $user->current_org_id)
            ->first();

        if (!$membership || !in_array($membership->role->value, $allowedRoles)) {
            return response()->json([
                'message' => 'Anda tidak memiliki izin untuk melakukan aksi ini.',
            ], 403);
        }

        return $next($request);
    }
}
