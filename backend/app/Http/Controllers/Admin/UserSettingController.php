<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\UserSetting;
use App\Support\AuditLogger;
use Illuminate\Http\Request;

class UserSettingController extends Controller
{
    public function index()
    {
        return response()->json(UserSetting::all());
    }

    public function show(UserSetting $userSetting)
    {
        $this->authorize('view', $userSetting);
        return response()->json($userSetting);
    }

    public function update(Request $request, UserSetting $userSetting)
    {
        $this->authorize('update', $userSetting);

        $data = $request->validate([
            'bahasa' => 'sometimes|in:id,en',
            'kecepatan_suara' => 'sometimes|numeric|min:0.25|max:1.0',
        ]);

        $userSetting->update($data);
        AuditLogger::log($userSetting->id_setting, 'setting_updated');

        return response()->json(['success' => true]);
    }
}