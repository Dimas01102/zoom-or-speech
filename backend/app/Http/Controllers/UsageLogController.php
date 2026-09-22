<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\UsageLogService;

/**
 * UC-012. Filter usage_logs dengan jenis_aktivitas = error.
 */
class UsageLogController extends Controller
{
    public function __construct(protected UsageLogService $usageLogService) {}

    public function index()
    {
        return response()->json($this->usageLogService->all());
    }

    public function errors()
    {
        return response()->json($this->usageLogService->errorsOnly());
    }

    public function destroy(string $id)
    {
        $this->usageLogService->delete($id);
        return response()->json(['success' => true]);
    }

    public function purge()
    {
        $this->usageLogService->purgeAll();
        return response()->json(['success' => true]);
    }
}
