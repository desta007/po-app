<?php

namespace App\Http\Controllers;

use App\Models\Organization;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class OrganizationLogoController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'logo' => ['required', 'image', 'mimes:jpg,jpeg,png,webp', 'max:1024'],
        ]);

        $org = auth()->user()->currentOrganization;

        // Delete old logo if exists
        if ($org->logo_url) {
            $oldPath = str_replace('/storage/', '', $org->logo_url);
            Storage::disk('public')->delete($oldPath);
        }

        $path = $request->file('logo')->store('logos', 'public');
        $org->update(['logo_url' => '/storage/' . $path]);

        return response()->json([
            'data' => ['logo_url' => $org->logo_url],
            'message' => 'Logo organisasi berhasil diupload.',
        ]);
    }

    public function destroy(): JsonResponse
    {
        $org = auth()->user()->currentOrganization;

        if ($org->logo_url) {
            $path = str_replace('/storage/', '', $org->logo_url);
            Storage::disk('public')->delete($path);
            $org->update(['logo_url' => null]);
        }

        return response()->json(['message' => 'Logo berhasil dihapus.']);
    }
}
