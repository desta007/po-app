<?php

namespace App\Models;

use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Laravel\Sanctum\PersonalAccessToken;

class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'full_name',
        'phone',
        'avatar_url',
        'current_org_id',
        'is_super_admin',
        'is_active',
        'must_change_password',
        'last_login_at',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'is_super_admin' => 'boolean',
            'is_active' => 'boolean',
            'must_change_password' => 'boolean',
            'last_login_at' => 'datetime',
        ];
    }

    /**
     * Hapus semua token Sanctum milik user kecuali token yang sedang dipakai
     * (dipanggil setelah ganti password agar sesi di perangkat lain berakhir).
     */
    public function revokeOtherTokens(): void
    {
        $query = $this->tokens();

        $current = $this->currentAccessToken();
        if ($current instanceof PersonalAccessToken) {
            $query->whereKeyNot($current->getKey());
        }

        $query->delete();
    }

    public function currentOrganization(): BelongsTo
    {
        return $this->belongsTo(Organization::class, 'current_org_id');
    }

    public function organizationMemberships(): HasMany
    {
        return $this->hasMany(OrganizationMember::class);
    }

    public function notifications(): HasMany
    {
        return $this->hasMany(\App\Models\Notification::class);
    }
}
