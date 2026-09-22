<?php

namespace App\Models;

/**
 * Representasi dokumen koleksi konten.
 * Field: id_konten, judul, deskripsi, video, diperbarui_oleh.
 */
class KontenModel
{
    public function __construct(
        public string $idKonten,
        public string $judul,
        public string $deskripsi,
        public string $video,
        public ?string $diperbaruiOleh = null,
    ) {}

    public static function fromFirestore(string $id, array $data): self
    {
        return new self(
            idKonten: $id,
            judul: $data['judul'] ?? '',
            deskripsi: $data['deskripsi'] ?? '',
            video: $data['video'] ?? '',
            diperbaruiOleh: $data['diperbarui_oleh'] ?? null,
        );
    }

    public function toArray(): array
    {
        return [
            'judul' => $this->judul,
            'deskripsi' => $this->deskripsi,
            'video' => $this->video,
            'diperbarui_oleh' => $this->diperbaruiOleh,
        ];
    }
}
