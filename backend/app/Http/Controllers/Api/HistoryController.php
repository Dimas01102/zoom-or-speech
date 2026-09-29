<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\History;
use App\Support\AuditLogger;
use Illuminate\Http\Request;

class HistoryController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        return response()->json(
            History::where('id_user', $user->id_user)->orderByDesc('waktu_scan')->get(),
        );
    }

    public function store(Request $request)
    {
        $this->authorize('create', History::class);

        $data = $request->validate([
            'type' => 'required|in:zoom,tts',
            'teks_hasil' => 'required|string',
            'gambar' => 'nullable|string',
        ]);
        $data['id_user'] = $request->user()->id_user;
        $data['waktu_scan'] = now();

        $history = History::create($data);
        AuditLogger::log($data['id_user'], 'history_created');

        return response()->json($history, 201);
    }

    public function destroy(Request $request, History $history)
    {
        $this->authorize('delete', $history);

        $userId = $history->id_user;
        $history->delete();
        AuditLogger::log($userId, 'history_deleted');

        return response()->json(['success' => true]);
    }
}