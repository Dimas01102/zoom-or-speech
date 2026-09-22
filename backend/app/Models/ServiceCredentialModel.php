<?php

namespace App\Models;

/**
 * Representasi dokumen koleksi service_credentials.
 * Field: id_service, nama_layanan, status, tanggal_diperbarui.
 * Nilai kredensial ASLI tidak pernah disimpan di sini, hanya di .env Laravel.
 */
class ServiceCredentialModel
{
    public function __construct(
        public string $idService,
        public string $namaLayanan,
        public string $status,
        public ?string $tanggalDiperbarui = null,
    ) {}

    public static function fromFirestore(string $id, array $data): self
    {
        return new self(
            idService: $id,
            namaLayanan: $data['nama_layanan'] ?? '',
            status: $data['status'] ?? '',
            tanggalDiperbarui: $data['tanggal_diperbarui'] ?? null,
        );
    }

    public function toArray(): array
    {
        return [
            'nama_layanan' => $this->namaLayanan,
            'status' => $this->status,
            'tanggal_diperbarui' => $this->tanggalDiperbarui,
        ];
    }
}
