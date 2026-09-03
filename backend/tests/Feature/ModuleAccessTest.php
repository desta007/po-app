<?php

namespace Tests\Feature;

use App\Models\Organization;
use App\Models\OrganizationModule;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class ModuleAccessTest extends TestCase
{
    use RefreshDatabase;

    private function makeOrg(): Organization
    {
        $slug = 'org-' . Str::lower(Str::random(8));

        return Organization::create([
            'name' => 'Resto ' . $slug,
            'slug' => $slug,
            'phone' => '08123456789',
        ]);
    }

    private function attachModule(Organization $org, string $status, ?string $expiresAt): OrganizationModule
    {
        return OrganizationModule::create([
            'organization_id' => $org->id,
            'module' => 'resto',
            'status' => $status,
            'starts_at' => now(),
            'expires_at' => $expiresAt,
        ]);
    }

    public function test_has_module_true_when_active_and_not_expired(): void
    {
        $org = $this->makeOrg();
        $this->attachModule($org, 'active', now()->addDays(30)->toDateTimeString());

        $this->assertTrue($org->hasModule('resto'));
        $this->assertSame(['resto'], $org->activeModules());
    }

    public function test_has_module_true_when_active_without_expiry(): void
    {
        $org = $this->makeOrg();
        $this->attachModule($org, 'active', null);

        $this->assertTrue($org->hasModule('resto'));
    }

    public function test_has_module_false_when_expired(): void
    {
        $org = $this->makeOrg();
        $this->attachModule($org, 'active', now()->subDay()->toDateTimeString());

        $this->assertFalse($org->hasModule('resto'));
        $this->assertSame([], $org->activeModules());
    }

    public function test_has_module_false_when_inactive_status(): void
    {
        $org = $this->makeOrg();
        $this->attachModule($org, 'inactive', now()->addDays(30)->toDateTimeString());

        $this->assertFalse($org->hasModule('resto'));
    }

    public function test_has_module_false_when_no_module_row(): void
    {
        $org = $this->makeOrg();

        $this->assertFalse($org->hasModule('resto'));
        $this->assertSame([], $org->activeModules());
    }
}
