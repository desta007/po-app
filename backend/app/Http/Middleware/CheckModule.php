<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckModule
{
    /**
     * Handle an incoming request.
     * Usage: middleware('module:resto')
     *
     * @param string $module Module code required to access the route
     */
    public function handle(Request $request, Closure $next, string $module): Response
    {
        $user = $request->user();

        if (!$user || !$user->current_org_id) {
            return response()->json([
                'message' => 'Anda belum memiliki organisasi.',
            ], 403);
        }

        // Super admin bypasses module checks
        if ($user->is_super_admin) {
            return $next($request);
        }

        $organization = $user->currentOrganization;

        if (!$organization || !$organization->hasModule($module)) {
            return response()->json([
                'message' => 'Organisasi Anda belum berlangganan modul ini.',
                'module_required' => true,
                'module' => $module,
            ], 403);
        }

        return $next($request);
    }
}
