<?php

namespace App\Models;

use App\Traits\BelongsToOrganization;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WaitlistEntry extends Model
{
    use HasUuids, BelongsToOrganization;

    protected $fillable = [
        'organization_id',
        'queue_number',
        'guest_name',
        'party_size',
        'phone',
        'status',
        'table_id',
        'table_label',
        'notes',
        'called_at',
        'call_count',
        'seated_at',
    ];

    protected function casts(): array
    {
        return [
            'queue_number' => 'integer',
            'party_size' => 'integer',
            'call_count' => 'integer',
            'called_at' => 'datetime',
            'seated_at' => 'datetime',
        ];
    }

    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    public function table(): BelongsTo
    {
        return $this->belongsTo(RestoTable::class, 'table_id');
    }
}
