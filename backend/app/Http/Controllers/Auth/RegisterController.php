<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\RegisterRequest;
use App\Models\Organization;
use App\Models\OrganizationMember;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class RegisterController extends Controller
{
    public function register(RegisterRequest $request): JsonResponse
    {
        $result = DB::transaction(function () use ($request) {
            // Create organization
            $org = Organization::create([
                'name' => $request->business_name,
                'slug' => Str::slug($request->business_name) . '-' . Str::random(4),
                'settings' => [
                    'timezone' => 'Asia/Jakarta',
                    'currency' => 'IDR',
                    'po_prefix' => 'PO',
                ],
            ]);

            // Create user
            $user = User::create([
                'name' => $request->full_name,
                'full_name' => $request->full_name,
                'email' => $request->email,
                'password' => $request->password,
                'phone' => $request->phone,
                'current_org_id' => $org->id,
            ]);

            // Link user to org as owner
            OrganizationMember::create([
                'organization_id' => $org->id,
                'user_id' => $user->id,
                'role' => 'owner',
            ]);

            return $user;
        });

        Auth::login($result);
        request()->session()->regenerate();

        return response()->json([
            'user' => $result->load('currentOrganization'),
        ], 201);
    }
}
