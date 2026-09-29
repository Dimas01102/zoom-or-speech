<?php

use App\Models\User;
use App\Support\AuditLogger;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
        then: function () {
            Route::middleware('web')->group(base_path('routes/admin.php'));
        },
    )
    ->withMiddleware(function (Middleware $middleware) {
        //
    })
    ->withExceptions(function (Exceptions $exceptions) {
        // Catat akses ditolak Policy ke usage_logs. Return null supaya
        // respons 403 bawaan Laravel tetap dipakai.
        $exceptions->render(function (AccessDeniedHttpException $e, Request $request) {
            try {
                $actor = $request->user();
                AuditLogger::log($actor instanceof User ? $actor->id_user : null, 'access_denied');
            } catch (\Throwable $ignored) {
                // Jangan sampai gagal log bikin error tambahan.
            }
            return null;
        });
    })->create();