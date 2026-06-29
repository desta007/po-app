<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LoginController extends Controller
{
    public function login(LoginRequest $request): JsonResponse
    {
        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'message' => 'Email atau password salah.',
            ], 401);
        }

        $user = Auth::user();
        $user->update(['last_login_at' => now()]);

        // Create Sanctum API token
        $token = $user->createToken('auth-token')->plainTextToken;

        // Get role in current organization
        $membership = $user->organizationMemberships()
            ->where('organization_id', $user->current_org_id)
            ->first();

        $organization = $user->currentOrganization;

        return response()->json([
            'user' => $user->load('currentOrganization'),
            'token' => $token,
            'role' => $membership?->role?->value,
            'is_super_admin' => (bool) $user->is_super_admin,
            'organization_plan' => $organization?->plan?->value ?? 'free',
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        // Delete the current access token
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Berhasil logout.']);
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->user();

        // Get role in current organization
        $membership = $user->organizationMemberships()
            ->where('organization_id', $user->current_org_id)
            ->first();

        $organization = $user->currentOrganization;

        return response()->json([
            'user' => $user->load('currentOrganization'),
            'role' => $membership?->role?->value,
            'is_super_admin' => (bool) $user->is_super_admin,
            'organization_plan' => $organization?->plan?->value ?? 'free',
        ]);
    }
}
