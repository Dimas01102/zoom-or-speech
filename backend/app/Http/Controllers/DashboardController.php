<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\HistoryService;
use App\Services\UsageLogService;

/**
 * Agregasi usage_logs dan history utk statistik.
 */
class DashboardController extends Controller
{
    public function __construct(
        protected HistoryService $historyService,
        protected UsageLogService $usageLogService,
    ) {}

    public function index()
    {
        $stats = [
            'scan_by_type' => $this->historyService->statsByType(),
            'total_errors' => count($this->usageLogService->errorsOnly()),
            'total_activity' => count($this->usageLogService->all()),
        ];

        // View dashboard menyusul belakangan.
        return response()->json($stats);
    }
}
