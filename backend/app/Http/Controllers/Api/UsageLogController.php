<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\UsageLog;
use Illuminate\Http\Request;

class UsageLogController extends Controller
{
    public function store(Request $request)
    {
        $this->authorize('create', UsageLog::class);

        $data = $request->validate([
            'jenis_aktivitas' => 'required|string|max:255',
        ]);

        UsageLog::create([
            // id_user WAJIB dari token, bukan dari body request.
            'id_user' => $request->user()->id_user,
            'jenis_aktivitas' => $data['jenis_aktivitas'],
            'waktu' => now(),
        ]);

        return response()->json(['success' => true], 201);
    }
}