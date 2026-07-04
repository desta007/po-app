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

        if (!$user->is_active) {
            Auth::guard('web')->logout();
            return response()->json([
                'message' => 'Akun Anda telah dinonaktifkan. Hubungi administrator untuk informasi lebih lanjut.',
            ], 403);
        }

        $user->update(['last_login_at' => now()]);

        // Create Sanctum API token
        $token = $user->createToken('auth-token')->plainTextToken;

        // Get role in current organization
        $membership = $user->organizationMemberships()
            ->where('organization_id', $user->current_org_id)
            ->first();

        $organization = $user->currentOrganization;

        // Check and expire subscription if past due
        $subscription = $organization?->checkSubscriptionExpiry();
        $organization?->refresh();

        return response()->json([
            'user' => $user->load('currentOrganization'),
            'token' => $token,
            'role' => $membership?->role?->value,
            'is_super_admin' => (bool) $user->is_super_admin,
            'organization_plan' => $organization?->plan?->value ?? 'free',
            'subscription' => $subscription ? [
                'status' => $subscription->status->value,
                'status_label' => $subscription->status->label(),
                'starts_at' => $subscription->starts_at,
                'expires_at' => $subscription->expires_at,
            ] : null,
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        // Delete the current access token
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Berhasil logout.']);
    }

    public function refresh(Request $request): JsonResponse
    {
        $user = $request->user();

        // Delete the current token
        $user->currentAccessToken()->delete();

        // Issue a new token
        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'token' => $token,
            'message' => 'Token berhasil diperbarui.',
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->user();

        // Get role in current organization
        $membership = $user->organizationMemberships()
            ->where('organization_id', $user->current_org_id)
            ->first();

        $organization = $user->currentOrganization;

        // Check and expire subscription if past due
        $subscription = $organization?->checkSubscriptionExpiry();
        $organization?->refresh();

        return response()->json([
            'user' => $user->load('currentOrganization'),
            'role' => $membership?->role?->value,
            'is_super_admin' => (bool) $user->is_super_admin,
            'organization_plan' => $organization?->plan?->value ?? 'free',
            'subscription' => $subscription ? [
                'status' => $subscription->status->value,
                'status_label' => $subscription->status->label(),
                'starts_at' => $subscription->starts_at,
                'expires_at' => $subscription->expires_at,
            ] : null,
        ]);
    }
}
