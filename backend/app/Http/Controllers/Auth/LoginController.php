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

        return response()->json([
            'user' => $user->load('currentOrganization'),
            'token' => $token,
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
        return response()->json([
            'user' => $request->user()->load('currentOrganization'),
        ]);
    }
}
