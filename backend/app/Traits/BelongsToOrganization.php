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

        // Prevent an existing record from being reassigned to another
        // organization via mass assignment on update (cross-tenant write).
        static::updating(function ($model) {
            if ($model->isDirty('organization_id')) {
                $model->organization_id = $model->getOriginal('organization_id');
            }
        });

        static::addGlobalScope('organization', function (Builder $builder) {
            // Only scope authenticated requests. Public/unauthenticated flows
            // (e.g. catalog checkout) filter by organization_id explicitly.
            if (!auth()->check()) {
                return;
            }

            $orgId = auth()->user()->current_org_id;

            // Fail closed: an authenticated user without an active organization
            // must never see cross-tenant rows.
            if (!$orgId) {
                $builder->whereRaw('1 = 0');

                return;
            }

            $builder->where(
                $builder->getModel()->getTable() . '.organization_id',
                $orgId
            );
        });
    }
}
