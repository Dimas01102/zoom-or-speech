<?php

namespace App\Models;

/**
 * Representasi dokumen koleksi history.
 * Field: id_history, id_user, waktu_scan, type (zoom|tts), teks_hasil, gambar.
 * Read-only dari sisi Admin, sesuai instruksi awal.
 */
class HistoryModel
{
    public function __construct(
        public string $idHistory,
        public string $idUser,
        public ?string $waktuScan,
        public string $type,
        public string $teksHasil,
        public ?string $gambar = null,
    ) {}

    public static function fromFirestore(string $id, array $data): self
    {
        return new self(
            idHistory: $id,
            idUser: $data['id_user'] ?? '',
            waktuScan: $data['waktu_scan'] ?? null,
            type: $data['type'] ?? '',
            teksHasil: $data['teks_hasil'] ?? '',
            gambar: $data['gambar'] ?? null,
        );
    }

    public function toArray(): array
    {
        return [
            'id_history' => $this->idHistory,
            'id_user' => $this->idUser,
            'waktu_scan' => $this->waktuScan,
            'type' => $this->type,
            'teks_hasil' => $this->teksHasil,
            'gambar' => $this->gambar,
        ];
    }
}
