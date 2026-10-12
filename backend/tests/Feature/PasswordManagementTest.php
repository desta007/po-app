<?php

namespace Tests\Feature;

use App\Models\Organization;
use App\Models\OrganizationMember;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

/**
 * Ganti password (self-service), reset password oleh super admin,
 * dan command darurat `user:reset-password`.
 */
class PasswordManagementTest extends TestCase
{
    use RefreshDatabase;

    private function makeMember(array $attrs = []): User
    {
        $org = Organization::create(['name' => 'Toko Kue', 'slug' => 'toko-kue-'.uniqid()]);

        $user = User::factory()->create(array_merge([
            'current_org_id' => $org->id,
            'password' => 'password-lama',
        ], $attrs));

        OrganizationMember::create([
            'organization_id' => $org->id,
            'user_id' => $user->id,
            'role' => 'owner',
            'joined_at' => now(),
        ]);

        return $user;
    }

    private function makeSuperAdmin(): User
    {
        return User::factory()->create([
            'is_super_admin' => true,
            'password' => 'password-admin',
        ]);
    }

    // ── Ganti password (PUT /api/auth/password) ───────────────────────────

    public function test_user_can_change_password_and_other_sessions_are_revoked(): void
    {
        $user = $this->makeMember();
        $current = $user->createToken('auth-token')->plainTextToken;
        $user->createToken('auth-token'); // sesi di perangkat lain

        $this->withToken($current)->putJson('/api/auth/password', [
            'current_password' => 'password-lama',
            'password' => 'password-baru',
            'password_confirmation' => 'password-baru',
        ])->assertOk();

        $user->refresh();
        $this->assertTrue(Hash::check('password-baru', $user->password));
        $this->assertSame(1, $user->tokens()->count(), 'Hanya sesi saat ini yang tersisa.');
    }

    public function test_change_password_rejects_wrong_current_password(): void
    {
        $user = $this->makeMember();
        $token = $user->createToken('auth-token')->plainTextToken;

        $this->withToken($token)->putJson('/api/auth/password', [
            'current_password' => 'salah',
            'password' => 'password-baru',
            'password_confirmation' => 'password-baru',
        ])->assertStatus(422)->assertJsonValidationErrors('current_password');

        $this->assertTrue(Hash::check('password-lama', $user->fresh()->password));
    }

    public function test_change_password_requires_new_password_different_from_current(): void
    {
        $user = $this->makeMember();
        $token = $user->createToken('auth-token')->plainTextToken;

        $this->withToken($token)->putJson('/api/auth/password', [
            'current_password' => 'password-lama',
            'password' => 'password-lama',
            'password_confirmation' => 'password-lama',
        ])->assertStatus(422)->assertJsonValidationErrors('password');
    }

    public function test_super_admin_without_organization_can_change_password(): void
    {
        $admin = $this->makeSuperAdmin();
        $token = $admin->createToken('auth-token')->plainTextToken;

        $this->withToken($token)->putJson('/api/auth/password', [
            'current_password' => 'password-admin',
            'password' => 'password-admin-baru',
            'password_confirmation' => 'password-admin-baru',
        ])->assertOk();

        $this->assertTrue(Hash::check('password-admin-baru', $admin->fresh()->password));
    }

    public function test_change_password_clears_must_change_password_flag(): void
    {
        $user = $this->makeMember(['must_change_password' => true]);
        $token = $user->createToken('auth-token')->plainTextToken;

        $this->withToken($token)->putJson('/api/auth/password', [
            'current_password' => 'password-lama',
            'password' => 'password-baru',
            'password_confirmation' => 'password-baru',
        ])->assertOk()->assertJsonPath('user.must_change_password', false);

        $this->assertFalse($user->fresh()->must_change_password);
    }

    public function test_profile_password_change_also_clears_flag_and_revokes_other_sessions(): void
    {
        $user = $this->makeMember(['must_change_password' => true]);
        $current = $user->createToken('auth-token')->plainTextToken;
        $user->createToken('auth-token');

        $this->withToken($current)->putJson('/api/settings/profile', [
            'full_name' => 'Budi',
            'current_password' => 'password-lama',
            'new_password' => 'password-baru',
            'new_password_confirmation' => 'password-baru',
        ])->assertOk();

        $user->refresh();
        $this->assertFalse($user->must_change_password);
        $this->assertSame(1, $user->tokens()->count());
    }

    // ── Reset oleh super admin (POST /api/admin/users/{id}/reset-password) ─

    public function test_super_admin_can_reset_user_password(): void
    {
        $admin = $this->makeSuperAdmin();
        $user = $this->makeMember();
        $user->createToken('auth-token');

        $response = $this->withToken($admin->createToken('auth-token')->plainTextToken)
            ->postJson("/api/admin/users/{$user->id}/reset-password")
            ->assertOk();

        $temporary = $response->json('temporary_password');
        $this->assertIsString($temporary);
        $this->assertGreaterThanOrEqual(10, strlen($temporary));

        $user->refresh();
        $this->assertTrue(Hash::check($temporary, $user->password));
        $this->assertTrue($user->must_change_password);
        $this->assertSame(0, $user->tokens()->count(), 'Semua sesi user harus diakhiri.');
    }

    public function test_login_with_temporary_password_reports_must_change_password(): void
    {
        // Keadaan setelah reset oleh super admin: password sementara + flag aktif.
        $user = $this->makeMember(['password' => 'sementara123', 'must_change_password' => true]);

        $this->postJson('/api/auth/login', ['email' => $user->email, 'password' => 'sementara123'])
            ->assertOk()
            ->assertJsonPath('user.must_change_password', true);
    }

    public function test_super_admin_cannot_reset_another_super_admin_via_api(): void
    {
        $admin = $this->makeSuperAdmin();
        $other = $this->makeSuperAdmin();

        $this->withToken($admin->createToken('auth-token')->plainTextToken)
            ->postJson("/api/admin/users/{$other->id}/reset-password")
            ->assertNotFound();
    }

    public function test_non_super_admin_cannot_reset_password(): void
    {
        $owner = $this->makeMember();
        $target = $this->makeMember();

        $this->withToken($owner->createToken('auth-token')->plainTextToken)
            ->postJson("/api/admin/users/{$target->id}/reset-password")
            ->assertForbidden();

        $this->assertTrue(Hash::check('password-lama', $target->fresh()->password));
    }

    // ── Command darurat ───────────────────────────────────────────────────

    public function test_command_resets_super_admin_password_interactively(): void
    {
        $admin = $this->makeSuperAdmin();
        $admin->createToken('auth-token');

        $this->artisan('user:reset-password', ['email' => $admin->email])
            ->expectsQuestion('Password baru (min. 8 karakter)', 'rahasia-baru')
            ->expectsQuestion('Ulangi password baru', 'rahasia-baru')
            ->assertSuccessful();

        $admin->refresh();
        $this->assertTrue(Hash::check('rahasia-baru', $admin->password));
        $this->assertFalse($admin->must_change_password);
        $this->assertSame(0, $admin->tokens()->count());
    }

    public function test_command_rejects_mismatched_confirmation(): void
    {
        $admin = $this->makeSuperAdmin();

        $this->artisan('user:reset-password', ['email' => $admin->email])
            ->expectsQuestion('Password baru (min. 8 karakter)', 'rahasia-baru')
            ->expectsQuestion('Ulangi password baru', 'beda-sekali')
            ->assertFailed();

        $this->assertTrue(Hash::check('password-admin', $admin->fresh()->password));
    }

    public function test_command_generate_with_force_change(): void
    {
        $user = $this->makeMember();

        $this->artisan('user:reset-password', [
            'email' => $user->email,
            '--generate' => true,
            '--force-change' => true,
        ])->assertSuccessful();

        $user->refresh();
        $this->assertFalse(Hash::check('password-lama', $user->password));
        $this->assertTrue($user->must_change_password);
    }

    public function test_command_fails_for_unknown_email(): void
    {
        $this->artisan('user:reset-password', ['email' => 'tidak-ada@example.com'])
            ->assertFailed();
    }
}
