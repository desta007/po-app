<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

/**
 * Ganti password oleh user yang sedang login. Hanya butuh `auth:sanctum`
 * (tanpa `org.access`) agar super admin — yang tak punya organisasi — juga bisa.
 */
class ChangePasswordController extends Controller
{
    public function update(Request $request): JsonResponse
    {
        $request->validate([
            'current_password' => 'required|string',
            'password' => 'required|string|min:8|confirmed|different:current_password',
        ], [
            'password.different' => 'Password baru harus berbeda dari password saat ini.',
        ]);

        $user = $request->user();

        if (! Hash::check($request->current_password, $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => 'Password saat ini salah.',
            ]);
        }

        $user->forceFill([
            'password' => $request->password,
            'must_change_password' => false,
        ])->save();

        // Akhiri sesi di perangkat lain; sesi saat ini tetap login.
        $user->revokeOtherTokens();

        return response()->json([
            'message' => 'Password berhasil diubah.',
            'user' => $user->fresh(),
        ]);
    }
}
