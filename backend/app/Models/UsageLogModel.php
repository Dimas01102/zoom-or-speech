<?php

namespace App\Models;

/**
 * Representasi dokumen koleksi usage_logs.
 * Field: id_usage, id_user (nullable), jenis_aktivitas, waktu.
 * Tidak ada koleksi crash_logs terpisah, error masuk sini dengan
 * jenis_aktivitas = "error".
 */
class UsageLogModel
{
    public function __construct(
        public string $idUsage,
        public ?string $idUser,
        public string $jenisAktivitas,
        public ?string $waktu,
    ) {}

    public static function fromFirestore(string $id, array $data): self
    {
        return new self(
            idUsage: $id,
            idUser: $data['id_user'] ?? null,
            jenisAktivitas: $data['jenis_aktivitas'] ?? '',
            waktu: $data['waktu'] ?? null,
        );
    }

    public function toArray(): array
    {
        return [
            'id_usage' => $this->idUsage,
            'id_user' => $this->idUser,
            'jenis_aktivitas' => $this->jenisAktivitas,
            'waktu' => $this->waktu,
        ];
    }
}
