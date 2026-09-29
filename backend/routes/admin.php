<?php

use App\Http\Controllers\Admin\AdminController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\HistoryMonitorController;
use App\Http\Controllers\Admin\ServiceCredentialController;
use App\Http\Controllers\Admin\TutorialController;
use App\Http\Controllers\Admin\UsageLogController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\UserSettingController;
use Illuminate\Support\Facades\Route;

/**
 * Login/logout Admin sudah ditangani Filament sendiri di /admin/login.
 * Route di sini endpoint data tambahan, guard admin (Eloquent, session).
 */
Route::prefix('admin-api')->name('admin.')->middleware('auth:admin')->group(function () {
    Route::get('dashboard', [DashboardController::class, 'index'])->name('dashboard');

    Route::apiResource('tutorial', TutorialController::class)
        ->parameters(['tutorial' => 'konten'])
        ->except(['show']);

    Route::get('user-setting', [UserSettingController::class, 'index']);
    Route::get('user-setting/{userSetting}', [UserSettingController::class, 'show']);
    Route::put('user-setting/{userSetting}', [UserSettingController::class, 'update']);

    Route::apiResource('user', UserController::class)->except(['store']);

    Route::get('history', [HistoryMonitorController::class, 'index']);
    Route::get('history/user/{userId}', [HistoryMonitorController::class, 'forUser']);

    Route::get('usage-log', [UsageLogController::class, 'index']);
    Route::get('usage-log/errors', [UsageLogController::class, 'errors']);
    Route::delete('usage-log/{usageLog}', [UsageLogController::class, 'destroy']);
    Route::delete('usage-log', [UsageLogController::class, 'purge']);

    Route::apiResource('service-credential', ServiceCredentialController::class)->except(['show']);

    Route::apiResource('admin-account', AdminController::class)
        ->parameters(['admin-account' => 'admin'])
        ->except(['show']);
});