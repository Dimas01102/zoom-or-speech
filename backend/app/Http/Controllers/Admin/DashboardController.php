<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Foundation\Validation\ValidatesRequests;
use App\Http\Controllers\Controller;
use App\Models\History;
use App\Models\UsageLog;

class DashboardController extends Controller
{
    public function index()
    {
        $stats = [
            'scan_by_type' => [
                'zoom' => History::where('type', 'zoom')->count(),
                'tts' => History::where('type', 'tts')->count(),
            ],
            'total_errors' => UsageLog::where('jenis_aktivitas', 'error')->count(),
            'total_activity' => UsageLog::count(),
        ];

        return response()->json($stats);
    }
}