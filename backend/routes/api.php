<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\HistoryController;
use App\Http\Controllers\Api\KontenController;
use App\Http\Controllers\Api\UsageLogController;
use App\Http\Controllers\Api\UserSettingController;
use Illuminate\Support\Facades\Route;

Route::post('auth/login', [AuthController::class, 'syncLogin'])->middleware('throttle:10,1');

Route::middleware('auth:user')->group(function () {
    Route::get('history', [HistoryController::class, 'index']);
    Route::post('history', [HistoryController::class, 'store']);
    Route::delete('history/{history}', [HistoryController::class, 'destroy']);

    Route::get('user-setting', [UserSettingController::class, 'show']);
    Route::put('user-setting', [UserSettingController::class, 'update']);

    Route::get('konten', [KontenController::class, 'index']);

    Route::post('usage-log', [UsageLogController::class, 'store']);
});