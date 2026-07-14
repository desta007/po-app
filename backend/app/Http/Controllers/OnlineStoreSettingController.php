<?php

namespace App\Http\Controllers;

use App\Models\Organization;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Facades\Http;

class OnlineStoreSettingController extends Controller
{
    /**
     * Return the online store config. The Midtrans server key is never sent
     * back to the client — only a flag indicating whether one is stored.
     */
    public function show(): JsonResponse
    {
        $org = auth()->user()->currentOrganization;

        return response()->json(['data' => $this->presentConfig($org)]);
    }

    /**
     * Persist the online store config (owner/admin only, premium only).
     */
    public function update(Request $request): JsonResponse
    {
        $org = auth()->user()->currentOrganization;

        if (! $org->isPremium() && ! auth()->user()->is_super_admin) {
            return response()->json([
                'message' => 'Fitur Toko Online hanya tersedia untuk paket Premium. Silakan upgrade untuk mengaktifkannya.',
            ], 403);
        }

        $validated = $request->validate([
            'midtrans' => ['nullable', 'array'],
            'midtrans.is_enabled' => ['nullable', 'boolean'],
            'midtrans.is_production' => ['nullable', 'boolean'],
            'midtrans.client_key' => ['nullable', 'string', 'max:255'],
            'midtrans.server_key' => ['nullable', 'string', 'max:255'],
            'shipping' => ['nullable', 'array'],
            'shipping.flat_rates' => ['nullable', 'array', 'max:20'],
            'shipping.flat_rates.*.name' => ['required', 'string', 'max:100'],
            'shipping.flat_rates.*.cost' => ['required', 'numeric', 'min:0'],
            'shipping.allow_pickup' => ['nullable', 'boolean'],
            'shipping.allow_shipping_tbd' => ['nullable', 'boolean'],
        ]);

        $settings = $org->settings ?? [];
        $current = $settings['online_store'] ?? [];
        $midtransIn = $validated['midtrans'] ?? [];
        $shippingIn = $validated['shipping'] ?? [];

        // --- Midtrans ---
        $midtrans = $current['midtrans'] ?? [];
        $midtrans['is_enabled'] = (bool) ($midtransIn['is_enabled'] ?? false);
        $midtrans['is_production'] = (bool) ($midtransIn['is_production'] ?? false);
        $midtrans['client_key'] = $midtransIn['client_key'] ?? ($midtrans['client_key'] ?? '');

        // Only overwrite the stored (encrypted) server key when the user typed a
        // real new value — a blank field means "keep the existing key".
        $incomingServerKey = $midtransIn['server_key'] ?? '';
        if ($incomingServerKey !== '' && ! $this->isMasked($incomingServerKey)) {
            $midtrans['server_key'] = Crypt::encryptString($incomingServerKey);
        }

        // Guard: cannot enable online payment without a stored server key.
        if ($midtrans['is_enabled'] && empty($midtrans['server_key'])) {
            return response()->json([
                'message' => 'Isi Server Key Midtrans terlebih dahulu sebelum mengaktifkan pembayaran online.',
            ], 422);
        }

        // --- Shipping ---
        $flatRates = $shippingIn['flat_rates'] ?? ($current['shipping']['flat_rates'] ?? []);
        $shipping = [
            'flat_rates' => array_values(array_map(fn ($rate) => [
                'name' => $rate['name'],
                'cost' => round((float) $rate['cost'], 2),
            ], $flatRates)),
            'allow_pickup' => (bool) ($shippingIn['allow_pickup'] ?? ($current['shipping']['allow_pickup'] ?? false)),
            'allow_shipping_tbd' => (bool) ($shippingIn['allow_shipping_tbd'] ?? ($current['shipping']['allow_shipping_tbd'] ?? false)),
        ];

        $settings['online_store'] = ['midtrans' => $midtrans, 'shipping' => $shipping];
        $org->update(['settings' => $settings]);

        return response()->json([
            'data' => $this->presentConfig($org->refresh()),
            'message' => 'Pengaturan toko online berhasil disimpan.',
        ]);
    }

    /**
     * Validate a Midtrans server key by hitting the transaction-status endpoint.
     * A 401 means the key is rejected; a 404 (order not found) means auth passed.
     */
    public function testMidtrans(Request $request): JsonResponse
    {
        $org = auth()->user()->currentOrganization;

        $request->validate([
            'server_key' => ['nullable', 'string', 'max:255'],
            'is_production' => ['nullable', 'boolean'],
        ]);

        $serverKey = $request->input('server_key');
        if (! $serverKey || $this->isMasked($serverKey)) {
            $serverKey = $org->midtransServerKey();
        }

        if (! $serverKey) {
            return response()->json(['message' => 'Server Key belum diisi.'], 422);
        }

        $isProduction = $request->boolean('is_production', (bool) ($org->onlineStore()['midtrans']['is_production'] ?? false));
        $base = $isProduction ? 'https://api.midtrans.com' : 'https://api.sandbox.midtrans.com';

        try {
            $response = Http::withBasicAuth($serverKey, '')
                ->acceptJson()
                ->timeout(10)
                ->get("{$base}/v2/poscheduler-connection-check/status");
        } catch (\Throwable) {
            return response()->json([
                'valid' => false,
                'message' => 'Tidak dapat menghubungi Midtrans. Periksa koneksi internet Anda.',
            ], 502);
        }

        if ($response->status() === 401) {
            return response()->json([
                'valid' => false,
                'message' => 'Server Key ditolak Midtrans. Pastikan key benar dan sesuai mode (Sandbox/Production).',
            ], 422);
        }

        return response()->json([
            'valid' => true,
            'message' => 'Koneksi Midtrans berhasil — Server Key valid (' . ($isProduction ? 'Production' : 'Sandbox') . ').',
        ]);
    }

    /**
     * Shape the config for the client, hiding the secret server key.
     *
     * @return array<string, mixed>
     */
    private function presentConfig(Organization $org): array
    {
        $store = $org->onlineStore();
        $midtrans = $store['midtrans'] ?? [];
        $hasServerKey = ! empty($midtrans['server_key']);

        return [
            'midtrans' => [
                'is_enabled' => (bool) ($midtrans['is_enabled'] ?? false),
                'is_production' => (bool) ($midtrans['is_production'] ?? false),
                'client_key' => $midtrans['client_key'] ?? '',
                'server_key_set' => $hasServerKey,
            ],
            'shipping' => [
                'flat_rates' => $store['shipping']['flat_rates'] ?? [],
                'allow_pickup' => (bool) ($store['shipping']['allow_pickup'] ?? false),
                'allow_shipping_tbd' => (bool) ($store['shipping']['allow_shipping_tbd'] ?? false),
            ],
        ];
    }

    private function isMasked(?string $value): bool
    {
        return $value !== null && str_contains($value, '•');
    }
}
