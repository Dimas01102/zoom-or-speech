<?php

namespace App\Models;

/**
 * Representasi dokumen koleksi user.
 * Field: id_user, username, email, tanggal_dibuat.
 */
class UserModel
{
    public function __construct(
        public string $idUser,
        public string $username,
        public string $email,
        public ?string $tanggalDibuat = null,
    ) {}

    public static function fromFirestore(string $id, array $data): self
    {
        return new self(
            idUser: $id,
            username: $data['username'] ?? '',
            email: $data['email'] ?? '',
            tanggalDibuat: $data['tanggal_dibuat'] ?? null,
        );
    }

    public function toArray(): array
    {
        return [
            'id_user' => $this->idUser,
            'username' => $this->username,
            'email' => $this->email,
            'tanggal_dibuat' => $this->tanggalDibuat,
        ];
    }
}
