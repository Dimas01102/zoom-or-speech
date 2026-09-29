<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\UserSetting;
use App\Support\AuditLogger;
use Illuminate\Http\Request;

class UserSettingController extends Controller
{
    public function show(Request $request)
    {
        $user = $request->user();

        $setting = UserSetting::firstOrCreate(
            ['id_setting' => $user->id_user],
            ['kecepatan_suara' => 0.5, 'bahasa' => 'id'],
        );

        return response()->json($setting);
    }

    public function update(Request $request)
    {
        $user = $request->user();

        $data = $request->validate([
            'bahasa' => 'sometimes|in:id,en',
            'kecepatan_suara' => 'sometimes|numeric|min:0.25|max:1.0',
        ]);

        $setting = UserSetting::firstOrCreate(
            ['id_setting' => $user->id_user],
            ['kecepatan_suara' => 0.5, 'bahasa' => 'id'],
        );

        $this->authorize('update', $setting);

        $setting->update($data);
        AuditLogger::log($user->id_user, 'setting_updated');

        return response()->json($setting);
    }
}