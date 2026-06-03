<?php

namespace App\Traits;

use Illuminate\Database\Eloquent\Builder;

/**
 * Scope queries to the current user's active organization.
 */
trait BelongsToOrganization
{
    public static function bootBelongsToOrganization(): void
    {
        static::creating(function ($model) {
            if (auth()->check() && empty($model->organization_id)) {
                $model->organization_id = auth()->user()->current_org_id;
            }
        });

        static::addGlobalScope('organization', function (Builder $builder) {
            if (auth()->check() && auth()->user()->current_org_id) {
                $builder->where(
                    $builder->getModel()->getTable() . '.organization_id',
                    auth()->user()->current_org_id
                );
            }
        });
    }
}
