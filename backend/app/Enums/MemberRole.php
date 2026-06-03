<?php

namespace App\Enums;

enum MemberRole: string
{
    case OWNER = 'owner';
    case ADMIN = 'admin';
    case STAFF = 'staff';
    case VIEWER = 'viewer';

    public function label(): string
    {
        return match ($this) {
            self::OWNER => 'Pemilik',
            self::ADMIN => 'Admin',
            self::STAFF => 'Staff',
            self::VIEWER => 'Viewer',
        };
    }
}
