<?php

namespace App\Http\Controllers;

use App\Enums\MemberRole;
use App\Models\OrganizationMember;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class TeamMemberController extends Controller
{
    public function index(): JsonResponse
    {
        $orgId = auth()->user()->current_org_id;

        $members = OrganizationMember::where('organization_id', $orgId)
            ->with('user:id,name,full_name,email,phone,avatar_url,last_login_at')
            ->orderByRaw("CASE role WHEN 'owner' THEN 1 WHEN 'admin' THEN 2 WHEN 'staff' THEN 3 WHEN 'viewer' THEN 4 END")
            ->get()
            ->map(fn ($m) => [
                'id' => $m->id,
                'user_id' => $m->user_id,
                'user_name' => $m->user->full_name ?? $m->user->name,
                'user_email' => $m->user->email,
                'user_phone' => $m->user->phone,
                'user_avatar' => $m->user->avatar_url,
                'last_login_at' => $m->user->last_login_at,
                'role' => $m->role->value,
                'role_label' => $m->role->label(),
                'joined_at' => $m->joined_at,
            ]);

        return response()->json(['data' => $members]);
    }

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
            'role' => ['required', Rule::in(['admin', 'staff', 'viewer'])],
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'message' => 'User dengan email tersebut belum terdaftar di PO Scheduler. Minta mereka untuk register terlebih dahulu.',
            ], 422);
        }

        $orgId = auth()->user()->current_org_id;

        // Check if already a member
        $existing = OrganizationMember::where('organization_id', $orgId)
            ->where('user_id', $user->id)
            ->first();

        if ($existing) {
            return response()->json([
                'message' => 'User ini sudah menjadi anggota organisasi Anda.',
            ], 422);
        }

        $member = OrganizationMember::create([
            'organization_id' => $orgId,
            'user_id' => $user->id,
            'role' => $request->role,
            'invited_by' => auth()->id(),
            'joined_at' => now(),
        ]);

        // Set current_org_id if user doesn't have one
        if (!$user->current_org_id) {
            $user->update(['current_org_id' => $orgId]);
        }

        return response()->json([
            'data' => [
                'id' => $member->id,
                'user_id' => $user->id,
                'user_name' => $user->full_name ?? $user->name,
                'user_email' => $user->email,
                'user_phone' => $user->phone,
                'user_avatar' => $user->avatar_url,
                'last_login_at' => $user->last_login_at,
                'role' => $member->role->value,
                'role_label' => MemberRole::from($request->role)->label(),
                'joined_at' => $member->joined_at,
            ],
            'message' => 'Anggota berhasil ditambahkan.',
        ], 201);
    }

    public function update(Request $request, string $id): JsonResponse
    {
        $request->validate([
            'role' => ['required', Rule::in(['owner', 'admin', 'staff', 'viewer'])],
        ]);

        $member = OrganizationMember::where('organization_id', auth()->user()->current_org_id)
            ->findOrFail($id);

        // Cannot change your own role
        if ($member->user_id === auth()->id()) {
            return response()->json([
                'message' => 'Anda tidak dapat mengubah role Anda sendiri.',
            ], 422);
        }

        $member->update(['role' => $request->role]);

        return response()->json([
            'message' => "Role berhasil diubah menjadi {$member->role->label()}.",
        ]);
    }

    public function destroy(string $id): JsonResponse
    {
        $orgId = auth()->user()->current_org_id;

        $member = OrganizationMember::where('organization_id', $orgId)
            ->findOrFail($id);

        // Cannot remove yourself
        if ($member->user_id === auth()->id()) {
            return response()->json([
                'message' => 'Anda tidak dapat menghapus diri sendiri dari organisasi.',
            ], 422);
        }

        // Cannot remove the last owner
        if ($member->role === MemberRole::OWNER) {
            $ownerCount = OrganizationMember::where('organization_id', $orgId)
                ->where('role', 'owner')
                ->count();

            if ($ownerCount <= 1) {
                return response()->json([
                    'message' => 'Tidak dapat menghapus owner terakhir. Tetapkan owner lain terlebih dahulu.',
                ], 422);
            }
        }

        $member->delete();

        return response()->json(['message' => 'Anggota berhasil dihapus dari organisasi.']);
    }
}
