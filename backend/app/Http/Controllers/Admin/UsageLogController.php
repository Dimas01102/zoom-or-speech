<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\UsageLog;

class UsageLogController extends Controller
{
    public function index()
    {
        $this->authorize('viewAny', UsageLog::class);
        return response()->json(UsageLog::all());
    }

    public function errors()
    {
        $this->authorize('viewAny', UsageLog::class);
        return response()->json(UsageLog::where('jenis_aktivitas', 'error')->get());
    }

    public function destroy(UsageLog $usageLog)
    {
        $this->authorize('delete', UsageLog::class);
        $usageLog->delete();
        return response()->json(['success' => true]);
    }

    public function purge()
    {
        $this->authorize('delete', UsageLog::class);
        UsageLog::query()->delete();
        return response()->json(['success' => true]);
    }
}