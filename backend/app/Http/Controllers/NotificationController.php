<?php

namespace App\Http\Controllers;

use App\Http\Resources\NotificationResource;
use App\Models\Notification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class NotificationController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = Notification::where('user_id', auth()->id())->inApp();

        if (auth()->user()->current_org_id) {
            $query->where('organization_id', auth()->user()->current_org_id);
        }

        $notifications = $query->orderByDesc('created_at')
            ->paginate($request->input('per_page', 20));

        return NotificationResource::collection($notifications);
    }

    public function unreadCount(): JsonResponse
    {
        $query = Notification::where('user_id', auth()->id())->inApp()->unread();

        if (auth()->user()->current_org_id) {
            $query->where('organization_id', auth()->user()->current_org_id);
        }

        return response()->json(['data' => ['count' => $query->count()]]);
    }

    public function markRead(string $id): JsonResponse
    {
        $notification = Notification::where('user_id', auth()->id())
            ->findOrFail($id);

        $notification->update(['read_at' => now()]);

        return response()->json(['message' => 'Notifikasi ditandai telah dibaca.']);
    }

    public function markAllRead(): JsonResponse
    {
        $query = Notification::where('user_id', auth()->id())->inApp()->unread();

        if (auth()->user()->current_org_id) {
            $query->where('organization_id', auth()->user()->current_org_id);
        }

        $query->update(['read_at' => now()]);

        return response()->json(['message' => 'Semua notifikasi ditandai telah dibaca.']);
    }
}
