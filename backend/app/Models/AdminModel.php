<?php

namespace App\Models;

/**
 * Representasi dokumen koleksi admin.
 * Field: id_admin, username, password (hashed).
 */
class AdminModel
{
    public function __construct(
        public string $idAdmin,
        public string $username,
        public string $password,
    ) {}

    public static function fromFirestore(string $id, array $data): self
    {
        return new self(
            idAdmin: $id,
            username: $data['username'] ?? '',
            password: $data['password'] ?? '',
        );
    }

    public function toArray(): array
    {
        return [
            'id_admin' => $this->idAdmin,
            'username' => $this->username,
            'password' => $this->password,
        ];
    }
}
