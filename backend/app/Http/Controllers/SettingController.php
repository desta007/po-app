<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class SettingController extends Controller
{
    public function getOrganization(): JsonResponse
    {
        $org = auth()->user()->currentOrganization;
        return response()->json(['data' => $org]);
    }

    public function updateOrganization(Request $request): JsonResponse
    {
        $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'phone' => 'nullable|string|max:20',
            'address' => 'nullable|string',
            'logo_url' => 'nullable|string',
        ]);

        $org = auth()->user()->currentOrganization;
        $org->update($request->only('name', 'phone', 'address', 'logo_url'));

        return response()->json(['data' => $org, 'message' => 'Organisasi berhasil diperbarui.']);
    }

    public function updateProfile(Request $request): JsonResponse
    {
        $request->validate([
            'full_name' => 'sometimes|required|string|max:255',
            'phone' => 'nullable|string|max:20',
            'avatar_url' => 'nullable|string',
            'current_password' => 'required_with:new_password|string',
            'new_password' => 'nullable|string|min:8|confirmed',
        ]);

        $user = auth()->user();

        if ($request->filled('new_password')) {
            if (!Hash::check($request->current_password, $user->password)) {
                return response()->json(['message' => 'Password lama salah.'], 422);
            }
            $user->password = $request->new_password;
        }

        $user->fill($request->only('full_name', 'phone', 'avatar_url'));
        $user->name = $request->input('full_name', $user->name);
        $user->save();

        return response()->json(['data' => $user, 'message' => 'Profil berhasil diperbarui.']);
    }

    public function updateNotificationPrefs(Request $request): JsonResponse
    {
        $request->validate([
            'email_reminder' => 'nullable|boolean',
            'wa_reminder' => 'nullable|boolean',
            'reminder_time' => 'nullable|string',
        ]);

        $org = auth()->user()->currentOrganization;
        $settings = $org->settings ?? [];
        $settings['notification_prefs'] = $request->only('email_reminder', 'wa_reminder', 'reminder_time');
        $org->update(['settings' => $settings]);

        return response()->json(['data' => $org, 'message' => 'Preferensi notifikasi berhasil diperbarui.']);
    }
}
