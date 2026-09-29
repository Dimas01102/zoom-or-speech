<?php

namespace App\Providers;

use App\Models\User;
use App\Support\AuditLogger;
use Illuminate\Auth\Events\Failed;
use Illuminate\Auth\Events\Login;
use Illuminate\Auth\Events\Logout;
use Illuminate\Database\UniqueConstraintViolationException;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\ServiceProvider;
use Kreait\Firebase\Contract\Auth as FirebaseAuth;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(): void
    {
        // Guard user: verifikasi Firebase ID Token per request, lalu cocokkan
        // firebase_uid ke tabel user. Bukan session, bukan Sanctum.
        Auth::viaRequest('firebase', function ($request) {
            $token = $request->bearerToken();
            if (!$token) {
                return null;
            }

            try {
                $verified = app(FirebaseAuth::class)->verifyIdToken($token);
                $claims = $verified->claims();
                $uid = $claims->get('sub');
                // Token Google membawa email & name, token tamu (anonymous) tidak.
                $email = $claims->get('email', null);
                $name = $claims->get('name', null);
            } catch (\Throwable $e) {
                AuditLogger::log(null, 'login_failed');
                return null;
            }

            try {
                $user = User::firstOrCreate(
                    ['firebase_uid' => $uid],
                    ['username' => $name ?: 'Pengguna', 'email' => $email ?: null, 'tanggal_dibuat' => now()],
                );
            } catch (UniqueConstraintViolationException $e) {
                // Request lain (mis. auth/login) baru saja membuat user yang sama.
                $user = User::where('firebase_uid', $uid)->first() ?? throw $e;
            }

            // Lengkapi data yang masih kosong dari token (tanpa menimpa yang sudah terisi).
            if (!$user->wasRecentlyCreated) {
                $fill = [];
                if ($user->email === null && $email) {
                    $fill['email'] = $email;
                }
                if ($user->username === 'Pengguna' && $name) {
                    $fill['username'] = $name;
                }
                if ($fill) {
                    try {
                        $user->update($fill);
                    } catch (\Throwable $ignored) {
                        // memastikan agar tidak gagal isi profil membuat request ditolak.
                    }
                }
            }

            return $user;
        });

        // Audit log login Admin (session guard memicu event standar Laravel).
        // id_user null karena Admin tidak ada di tabel user.
        Event::listen(Login::class, fn () => AuditLogger::log(null, 'login_success'));
        Event::listen(Failed::class, fn () => AuditLogger::log(null, 'login_failed'));
        Event::listen(Logout::class, fn () => AuditLogger::log(null, 'logout'));
    }
}