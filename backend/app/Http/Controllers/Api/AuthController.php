<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Support\AuditLogger;
use Illuminate\Database\UniqueConstraintViolationException;
use Illuminate\Http\Request;
use Kreait\Firebase\Contract\Auth as FirebaseAuth;

class AuthController extends Controller
{
    /**
     * Dipanggil mobile sekali sesaat abis Google/Guest sign-in berhasil.
     * Verifikasi manual di sini (bukan lewat middleware guard) supaya bisa
     * bikin baris user baru kalau memang belum ada.
     */
    public function syncLogin(Request $request, FirebaseAuth $firebaseAuth)
    {
        $token = $request->bearerToken();
        if (!$token) {
            return response()->json(['message' => 'Token tidak ada.'], 401);
        }

        try {
            $verified = $firebaseAuth->verifyIdToken($token);
            $uid = $verified->claims()->get('sub');
        } catch (\Throwable $e) {
            AuditLogger::log(null, 'login_failed');
            return response()->json(['message' => 'Token tidak valid.'], 401);
        }

        $data = $request->validate([
            'username' => 'required|string|max:255',
            'email' => 'nullable|email',
        ]);

        try {
            $user = User::firstOrCreate(
                ['firebase_uid' => $uid],
                ['tanggal_dibuat' => now(), 'username' => $data['username'], 'email' => $data['email'] ?? null],
            );
        } catch (UniqueConstraintViolationException $e) {
            // Guard user sudah lebih dulu membuat baris yang sama (request paralel).
            $user = User::where('firebase_uid', $uid)->first() ?? throw $e;
        }

        if ($user->wasRecentlyCreated === false) {
            $user->update(['username' => $data['username'], 'email' => $data['email'] ?? $user->email]);
        }

        AuditLogger::log($user->id_user, 'login_success');

        return response()->json($user);
    }
}