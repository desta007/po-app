<?php

namespace App\Http\Controllers;

use App\Models\RestoTable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RestoTableController extends Controller
{
    /**
     * Table map for the current organization.
     */
    public function index(Request $request): JsonResponse
    {
        $query = RestoTable::query();

        if ($request->has('is_active')) {
            $query->where('is_active', $request->boolean('is_active'));
        }

        $tables = $query->orderBy('sort_order')->orderBy('label')->get();

        return response()->json(['data' => $tables]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'label' => ['required', 'string', 'max:50'],
            'capacity' => ['required', 'integer', 'min:1', 'max:100'],
            'sort_order' => ['nullable', 'integer'],
        ]);

        $table = RestoTable::create($validated);

        return response()->json([
            'data' => $table,
            'message' => 'Meja ditambahkan.',
        ], 201);
    }

    public function update(Request $request, string $id): JsonResponse
    {
        $table = RestoTable::findOrFail($id);

        $validated = $request->validate([
            'label' => ['sometimes', 'string', 'max:50'],
            'capacity' => ['sometimes', 'integer', 'min:1', 'max:100'],
            'is_active' => ['sometimes', 'boolean'],
            'sort_order' => ['sometimes', 'integer'],
        ]);

        $table->update($validated);

        return response()->json([
            'data' => $table,
            'message' => 'Meja diperbarui.',
        ]);
    }

    /**
     * Toggle table occupancy (e.g. "Kosongkan Meja" when guests leave).
     */
    public function updateStatus(Request $request, string $id): JsonResponse
    {
        $validated = $request->validate([
            'status' => ['required', 'in:available,occupied'],
        ]);

        $table = RestoTable::findOrFail($id);
        $table->update(['status' => $validated['status']]);

        return response()->json([
            'data' => $table,
            'message' => 'Status meja diperbarui.',
        ]);
    }

    public function destroy(string $id): JsonResponse
    {
        $table = RestoTable::findOrFail($id);
        $table->delete();

        return response()->json(['message' => 'Meja dihapus.']);
    }
}
