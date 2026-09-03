<?php

namespace App\Http\Controllers;

use App\Jobs\SendWhatsAppNotification;
use App\Models\RestoTable;
use App\Models\WaitlistEntry;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WaitlistController extends Controller
{
    /**
     * Today's waiting list for the current organization.
     * Default returns active entries (waiting + called); ?status= filters,
     * ?all=1 returns every entry created today (incl. seated/cancelled).
     */
    public function index(Request $request): JsonResponse
    {
        $query = WaitlistEntry::whereDate('created_at', today())
            ->with('table:id,label');

        if ($status = $request->input('status')) {
            $query->where('status', $status);
        } elseif (!$request->boolean('all')) {
            $query->whereIn('status', ['waiting', 'called']);
        }

        $entries = $query->orderBy('queue_number')->get();

        return response()->json([
            'data' => $entries,
            'stats' => $this->todayStats(),
        ]);
    }

    /**
     * Add a guest to the waiting list.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'guest_name' => ['required', 'string', 'max:100'],
            'party_size' => ['required', 'integer', 'min:1', 'max:100'],
            'phone' => ['nullable', 'string', 'max:30'],
            'notes' => ['nullable', 'string', 'max:500'],
        ]);

        $validated['queue_number'] = $this->nextQueueNumber();
        $validated['status'] = 'waiting';

        $entry = WaitlistEntry::create($validated);

        return response()->json([
            'data' => $entry,
            'message' => 'Tamu ditambahkan ke antrian.',
        ], 201);
    }

    /**
     * Edit an existing entry (name / party size / phone / notes).
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $entry = WaitlistEntry::findOrFail($id);

        $validated = $request->validate([
            'guest_name' => ['sometimes', 'string', 'max:100'],
            'party_size' => ['sometimes', 'integer', 'min:1', 'max:100'],
            'phone' => ['nullable', 'string', 'max:30'],
            'notes' => ['nullable', 'string', 'max:500'],
        ]);

        $entry->update($validated);

        return response()->json([
            'data' => $entry,
            'message' => 'Antrian diperbarui.',
        ]);
    }

    /**
     * Call a guest — marks as called and returns the announcement text
     * the frontend speaks via Web Speech API.
     */
    public function call(Request $request, string $id): JsonResponse
    {
        $entry = WaitlistEntry::findOrFail($id);

        if (in_array($entry->status, ['cancelled', 'no_show'])) {
            return response()->json(['message' => 'Antrian ini sudah tidak aktif.'], 422);
        }

        $entry->update([
            'status' => 'called',
            'called_at' => now(),
            'call_count' => $entry->call_count + 1,
        ]);

        $announcement = "Panggilan atas nama {$entry->guest_name}, nomor antrian {$entry->queue_number}, silakan menuju kasir.";

        // Kirim notifikasi WhatsApp bila tamu meninggalkan nomor HP (async lewat queue worker).
        $notified = false;
        if ($entry->phone) {
            $orgName = $request->user()->currentOrganization?->name;
            $message = "Halo {$entry->guest_name}! 🔔 Giliran Anda sudah tiba"
                . ($orgName ? " di {$orgName}" : '')
                . ". Nomor antrian {$entry->queue_number}. Silakan menuju kasir. Terima kasih 🙏";
            SendWhatsAppNotification::dispatch($entry->phone, $message);
            $notified = true;
        }

        return response()->json([
            'data' => $entry,
            'announcement' => $announcement,
            'whatsapp_sent' => $notified,
            'message' => 'Tamu dipanggil.',
        ]);
    }

    /**
     * Seat a guest, optionally at a specific table (peta meja).
     */
    public function seat(Request $request, string $id): JsonResponse
    {
        $validated = $request->validate([
            'table_id' => ['nullable', 'string'],
        ]);

        $entry = WaitlistEntry::findOrFail($id);

        $table = null;
        if (!empty($validated['table_id'])) {
            // findOrFail is tenant-scoped, so a cross-org table id 404s.
            $table = RestoTable::findOrFail($validated['table_id']);
        }

        $entry->update([
            'status' => 'seated',
            'seated_at' => now(),
            'table_id' => $table?->id,
            'table_label' => $table?->label,
        ]);

        if ($table) {
            $table->update(['status' => 'occupied']);
        }

        return response()->json([
            'data' => $entry->load('table:id,label'),
            'message' => 'Tamu telah duduk.',
        ]);
    }

    /**
     * Cancel an entry (voluntary cancel or no-show). Frees its table if seated.
     */
    public function cancel(Request $request, string $id): JsonResponse
    {
        $validated = $request->validate([
            'status' => ['required', 'in:cancelled,no_show'],
        ]);

        $entry = WaitlistEntry::findOrFail($id);

        if ($entry->table_id && $entry->status === 'seated') {
            RestoTable::where('id', $entry->table_id)->update(['status' => 'available']);
        }

        $entry->update(['status' => $validated['status']]);

        return response()->json([
            'data' => $entry,
            'message' => $validated['status'] === 'no_show' ? 'Ditandai tidak hadir.' : 'Antrian dibatalkan.',
        ]);
    }

    /**
     * Public-in-app display feed for the queue TV screen (all members).
     */
    public function display(): JsonResponse
    {
        $called = WaitlistEntry::whereDate('created_at', today())
            ->where('status', 'called')
            ->orderByDesc('called_at')
            ->limit(5)
            ->get(['id', 'queue_number', 'guest_name', 'called_at', 'call_count']);

        $waiting = WaitlistEntry::whereDate('created_at', today())
            ->where('status', 'waiting')
            ->orderBy('queue_number')
            ->limit(10)
            ->get(['id', 'queue_number', 'guest_name', 'party_size']);

        return response()->json([
            'called' => $called,
            'waiting' => $waiting,
            'stats' => $this->todayStats(),
        ]);
    }

    /**
     * Next daily queue number for the current organization (resets each day).
     */
    private function nextQueueNumber(): int
    {
        $max = WaitlistEntry::whereDate('created_at', today())->max('queue_number');

        return ($max ?? 0) + 1;
    }

    /**
     * @return array<string, int>
     */
    private function todayStats(): array
    {
        $counts = WaitlistEntry::whereDate('created_at', today())
            ->selectRaw('status, count(*) as total')
            ->groupBy('status')
            ->pluck('total', 'status');

        return [
            'waiting' => (int) ($counts['waiting'] ?? 0),
            'called' => (int) ($counts['called'] ?? 0),
            'seated' => (int) ($counts['seated'] ?? 0),
            'cancelled' => (int) ($counts['cancelled'] ?? 0),
            'no_show' => (int) ($counts['no_show'] ?? 0),
        ];
    }
}
