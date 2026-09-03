<?php

namespace App\Http\Controllers;

use App\Enums\OrganizationModule as OrganizationModuleEnum;
use App\Enums\SubscriptionPlan;
use App\Enums\SubscriptionStatus;
use App\Models\Organization;
use App\Models\OrganizationModule;
use App\Models\Subscription;
use App\Models\User;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SubscriptionController extends Controller
{
    /**
     * Get current subscription status for authenticated user's organization.
     */
    public function status(Request $request): JsonResponse
    {
        $user = $request->user();
        $organization = $user->currentOrganization;

        if (!$organization) {
            return response()->json(['message' => 'Organisasi tidak ditemukan.'], 404);
        }

        $latestSubscription = Subscription::where('organization_id', $organization->id)
            ->orderByDesc('created_at')
            ->first();

        return response()->json([
            'plan' => $organization->plan?->value ?? 'free',
            'plan_label' => $organization->plan?->label() ?? 'Gratis',
            'is_premium' => $organization->isPremium(),
            'modules' => $organization->modules()
                ->orderBy('module')
                ->get()
                ->map(fn ($m) => [
                    'module' => $m->module instanceof OrganizationModuleEnum ? $m->module->value : $m->module,
                    'label' => $m->module instanceof OrganizationModuleEnum ? $m->module->label() : $m->module,
                    'status' => $m->status,
                    'starts_at' => $m->starts_at,
                    'expires_at' => $m->expires_at,
                    'is_active' => $organization->hasModule($m->module instanceof OrganizationModuleEnum ? $m->module->value : $m->module),
                ]),
            'active_modules' => $organization->activeModules(),
            'latest_subscription' => $latestSubscription ? [
                'id' => $latestSubscription->id,
                'status' => $latestSubscription->status->value,
                'status_label' => $latestSubscription->status->label(),
                'requested_at' => $latestSubscription->requested_at,
                'starts_at' => $latestSubscription->starts_at,
                'expires_at' => $latestSubscription->expires_at,
                'reject_reason' => $latestSubscription->reject_reason,
            ] : null,
        ]);
    }

    /**
     * Request upgrade to premium (user action).
     */
    public function requestUpgrade(Request $request): JsonResponse
    {
        $request->validate([
            'payment_proof_note' => ['nullable', 'string', 'max:1000'],
            'module' => ['nullable', 'string', 'in:' . implode(',', array_column(OrganizationModuleEnum::cases(), 'value'))],
        ]);

        $user = $request->user();
        $organization = $user->currentOrganization;

        if (!$organization) {
            return response()->json(['message' => 'Organisasi tidak ditemukan.'], 404);
        }

        $module = $request->filled('module')
            ? OrganizationModuleEnum::from($request->input('module'))
            : null;

        if ($module) {
            return $this->requestModule($request, $organization, $user, $module);
        }

        if ($organization->isPremium()) {
            return response()->json(['message' => 'Organisasi Anda sudah berlangganan Premium.'], 422);
        }

        // Check if there's already a pending plan-upgrade request (module requests excluded)
        $pendingExists = Subscription::where('organization_id', $organization->id)
            ->whereNull('module')
            ->where('status', SubscriptionStatus::PENDING)
            ->exists();

        if ($pendingExists) {
            return response()->json(['message' => 'Anda sudah memiliki permintaan upgrade yang sedang diproses.'], 422);
        }

        $subscription = Subscription::create([
            'organization_id' => $organization->id,
            'plan' => SubscriptionPlan::PREMIUM,
            'status' => SubscriptionStatus::PENDING,
            'amount' => 50000,
            'requested_by' => $user->id,
            'payment_proof_note' => $request->input('payment_proof_note'),
            'requested_at' => now(),
        ]);

        return response()->json([
            'data' => $subscription,
            'message' => 'Permintaan upgrade berhasil dikirim. Silakan tunggu konfirmasi dari admin.',
        ], 201);
    }

    /**
     * Request a subscription for an add-on module (e.g. Resto).
     */
    private function requestModule(Request $request, Organization $organization, User $user, OrganizationModuleEnum $module): JsonResponse
    {
        if ($organization->hasModule($module->value)) {
            return response()->json(['message' => 'Organisasi Anda sudah berlangganan modul ' . $module->label() . '.'], 422);
        }

        $pendingExists = Subscription::where('organization_id', $organization->id)
            ->where('module', $module->value)
            ->where('status', SubscriptionStatus::PENDING)
            ->exists();

        if ($pendingExists) {
            return response()->json(['message' => 'Anda sudah memiliki permintaan langganan modul ini yang sedang diproses.'], 422);
        }

        $subscription = Subscription::create([
            'organization_id' => $organization->id,
            'plan' => SubscriptionPlan::PREMIUM,
            'module' => $module->value,
            'status' => SubscriptionStatus::PENDING,
            'amount' => $module->price(),
            'requested_by' => $user->id,
            'payment_proof_note' => $request->input('payment_proof_note'),
            'requested_at' => now(),
        ]);

        return response()->json([
            'data' => $subscription,
            'message' => 'Permintaan langganan modul ' . $module->label() . ' berhasil dikirim. Silakan tunggu konfirmasi dari admin.',
        ], 201);
    }

    /**
     * List all subscription requests (super admin).
     */
    public function subscriptions(Request $request): JsonResponse
    {
        $query = Subscription::with([
            'organization:id,name,slug',
            'requester:id,full_name,email,phone',
            'approver:id,full_name,email',
        ]);

        if ($status = $request->input('status')) {
            $query->where('status', $status);
        }

        if ($search = $request->input('search')) {
            $query->whereHas('organization', function ($q) use ($search) {
                $q->where('name', 'ilike', "%{$search}%");
            })->orWhereHas('requester', function ($q) use ($search) {
                $q->where('full_name', 'ilike', "%{$search}%")
                  ->orWhere('email', 'ilike', "%{$search}%");
            });
        }

        $subscriptions = $query->orderByDesc('created_at')
            ->paginate($request->input('per_page', 20));

        $subscriptions->getCollection()->transform(function ($sub) {
            return [
                'id' => $sub->id,
                'organization_name' => $sub->organization?->name,
                'organization_slug' => $sub->organization?->slug,
                'requester_name' => $sub->requester?->full_name,
                'requester_email' => $sub->requester?->email,
                'requester_phone' => $sub->requester?->phone,
                'plan' => $sub->plan->value,
                'plan_label' => $sub->plan->label(),
                'module' => $sub->module instanceof OrganizationModuleEnum ? $sub->module->value : $sub->module,
                'module_label' => $sub->module instanceof OrganizationModuleEnum ? $sub->module->label() : null,
                'status' => $sub->status->value,
                'status_label' => $sub->status->label(),
                'status_color' => $sub->status->color(),
                'amount' => (float) $sub->amount,
                'payment_proof_note' => $sub->payment_proof_note,
                'reject_reason' => $sub->reject_reason,
                'requested_at' => $sub->requested_at,
                'starts_at' => $sub->starts_at,
                'expires_at' => $sub->expires_at,
                'responded_at' => $sub->responded_at,
                'approver_name' => $sub->approver?->full_name,
            ];
        });

        return response()->json($subscriptions);
    }

    /**
     * Approve a subscription request (super admin).
     */
    public function approveSubscription(Request $request, string $id): JsonResponse
    {
        $subscription = Subscription::findOrFail($id);

        if ($subscription->status !== SubscriptionStatus::PENDING) {
            return response()->json(['message' => 'Hanya permintaan dengan status pending yang dapat disetujui.'], 422);
        }

        $startsAt = now();
        $expiresAt = now()->addDays(30);

        $subscription->update([
            'status' => SubscriptionStatus::ACTIVE,
            'approved_by' => $request->user()->id,
            'starts_at' => $startsAt,
            'expires_at' => $expiresAt,
            'responded_at' => now(),
        ]);

        // Module subscription → activate the add-on module, leave plan untouched.
        if ($subscription->module) {
            $moduleCode = $subscription->module instanceof OrganizationModuleEnum
                ? $subscription->module->value
                : $subscription->module;

            OrganizationModule::updateOrCreate(
                [
                    'organization_id' => $subscription->organization_id,
                    'module' => $moduleCode,
                ],
                [
                    'status' => 'active',
                    'starts_at' => $startsAt,
                    'expires_at' => $expiresAt,
                ]
            );

            $label = $subscription->module instanceof OrganizationModuleEnum
                ? $subscription->module->label()
                : $moduleCode;

            return response()->json([
                'message' => 'Langganan modul ' . $label . ' berhasil disetujui.',
            ]);
        }

        // Plan upgrade → set organization to Premium.
        $subscription->organization->update([
            'plan' => SubscriptionPlan::PREMIUM,
        ]);

        return response()->json([
            'message' => 'Subscription berhasil disetujui. Organisasi sekarang Premium.',
        ]);
    }

    /**
     * Reject a subscription request (super admin).
     */
    public function rejectSubscription(Request $request, string $id): JsonResponse
    {
        $request->validate([
            'reject_reason' => ['required', 'string', 'max:500'],
        ]);

        $subscription = Subscription::findOrFail($id);

        if ($subscription->status !== SubscriptionStatus::PENDING) {
            return response()->json(['message' => 'Hanya permintaan dengan status pending yang dapat ditolak.'], 422);
        }

        $subscription->update([
            'status' => SubscriptionStatus::REJECTED,
            'reject_reason' => $request->input('reject_reason'),
            'responded_at' => now(),
        ]);

        return response()->json([
            'message' => 'Subscription ditolak.',
        ]);
    }

    /**
     * Export subscription invoice as PDF.
     */
    public function exportInvoice(string $id): Response
    {
        $subscription = Subscription::with(['organization', 'requester', 'approver'])->findOrFail($id);

        if ($subscription->status !== SubscriptionStatus::ACTIVE) {
            return response()->json(['message' => 'Invoice hanya tersedia untuk subscription yang aktif.'], 422);
        }

        $invoiceNumber = 'INV-SUB-' . $subscription->starts_at->format('Ymd') . '-' . strtoupper(substr($subscription->id, 0, 8));

        $pdf = Pdf::loadView('pdf.subscription-invoice', [
            'subscription' => $subscription,
            'invoiceNumber' => $invoiceNumber,
        ])->setPaper('a4', 'portrait');

        $filename = $invoiceNumber . '.pdf';

        return $pdf->download($filename);
    }
}
