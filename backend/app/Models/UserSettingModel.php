<?php

namespace App\Models;

/**
 * Representasi dokumen koleksi user_setting. ID dokumen = id_user.
 * HANYA dua field: kecepatan_suara, bahasa. Jangan tambah field lain.
 */
class UserSettingModel
{
    public function __construct(
        public string $idUser,
        public float $kecepatanSuara,
        public string $bahasa,
    ) {}

    public static function fromFirestore(string $id, array $data): self
    {
        return new self(
            idUser: $id,
            kecepatanSuara: (float) ($data['kecepatan_suara'] ?? 0.5),
            bahasa: $data['bahasa'] ?? 'id',
        );
    }

    public function toArray(): array
    {
        return [
            'kecepatan_suara' => $this->kecepatanSuara,
            'bahasa' => $this->bahasa,
        ];
    }
}
