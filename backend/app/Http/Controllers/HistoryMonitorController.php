<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\HistoryService;

/**
 * Admin read-only ke history. Tidak ada method store/update/destroy
 * sengaja, sesuai instruksi awal admin tidak bisa insert/delete history.
 */
class HistoryMonitorController extends Controller
{
    public function __construct(protected HistoryService $historyService) {}

    public function index()
    {
        return response()->json($this->historyService->all());
    }

    public function forUser(string $userId)
    {
        return response()->json($this->historyService->forUser($userId));
    }
}
