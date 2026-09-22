<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\UserSettingService;
use Illuminate\Http\Request;

/**
 * UC-009. Admin lihat dan edit user_setting milik user manapun.
 */
class UserSettingController extends Controller
{
    public function __construct(protected UserSettingService $userSettingService) {}

    public function index()
    {
        return response()->json($this->userSettingService->all());
    }

    public function show(string $userId)
    {
        $setting = $this->userSettingService->find($userId);
        if (!$setting) {
            return response()->json(['message' => 'Tidak ditemukan.'], 404);
        }
        return response()->json($setting);
    }

    public function update(Request $request, string $userId)
    {
        $data = $request->validate([
            'bahasa' => 'sometimes|string',
            'kecepatan_suara' => 'sometimes|numeric',
        ]);

        $result = $this->userSettingService->update($userId, $data);

        if (!$result['success']) {
            return response()->json(['errors' => $result['errors']], 422);
        }
        return response()->json(['success' => true]);
    }
}
