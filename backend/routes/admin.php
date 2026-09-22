<?php

use App\Http\Controllers\Admin\AdminController;
use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\HistoryMonitorController;
use App\Http\Controllers\Admin\ServiceCredentialController;
use App\Http\Controllers\Admin\TutorialController;
use App\Http\Controllers\Admin\UsageLogController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\UserSettingController;
use Illuminate\Support\Facades\Route;

/**
 * Rate limiting pada login, 5 requests per minute.
 */
Route::prefix('admin')->name('admin.')->group(function () {
    Route::get('login', [AuthController::class, 'showLogin'])->name('login');
    Route::post('login', [AuthController::class, 'login'])
        ->middleware('throttle:5,1')
        ->name('login.submit');

    Route::middleware('admin.auth')->group(function () {
        Route::post('logout', [AuthController::class, 'logout'])->name('logout');

        Route::get('dashboard', [DashboardController::class, 'index'])->name('dashboard');

        Route::apiResource('tutorial', TutorialController::class)->except(['show']);

        Route::get('user-setting', [UserSettingController::class, 'index']);
        Route::get('user-setting/{userId}', [UserSettingController::class, 'show']);
        Route::put('user-setting/{userId}', [UserSettingController::class, 'update']);

        Route::apiResource('user', UserController::class)->except(['store']);

        // Read-only, tidak ada apiResource lengkap sengaja.
        Route::get('history', [HistoryMonitorController::class, 'index']);
        Route::get('history/user/{userId}', [HistoryMonitorController::class, 'forUser']);

        Route::get('usage-log', [UsageLogController::class, 'index']);
        Route::get('usage-log/errors', [UsageLogController::class, 'errors']);
        Route::delete('usage-log/{id}', [UsageLogController::class, 'destroy']);
        Route::delete('usage-log', [UsageLogController::class, 'purge']);

        Route::apiResource('service-credential', ServiceCredentialController::class)->except(['show']);

        Route::apiResource('admin-account', AdminController::class)->except(['show']);
    });
});