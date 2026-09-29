<?php

namespace App\Support;

use App\Models\UsageLog;

/**
 * login_success, login_failed,
 * logout, history_created, history_deleted, setting_updated,
 * user_updated, user_deleted, konten_created, konten_updated,
 * konten_deleted, credential_updated, error, access_denied.
 */
class AuditLogger
{
    public static function log(?int $userId, string $jenisAktivitas): void
    {
        UsageLog::create([
            'id_user' => $userId,
            'jenis_aktivitas' => $jenisAktivitas,
            'waktu' => now(),
        ]);
    }
}