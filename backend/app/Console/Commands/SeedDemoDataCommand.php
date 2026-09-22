<?php

namespace App\Console\Commands;

use App\Services\KontenService;
use App\Services\ServiceCredentialService;
use Illuminate\Console\Command;

/**
 * Bikin data contoh utk konten dan service_credentials, biar nggak perlu
 * isi manual satu-satu lewat Firebase Console.
 */
class SeedDemoDataCommand extends Command
{
    protected $signature = 'app:seed-demo';

    protected $description = 'Bikin data contoh konten dan service_credentials';

    public function handle(KontenService $kontenService, ServiceCredentialService $serviceCredentialService): int
    {
        $kontenId = $kontenService->create([
            'judul' => 'Cara Memindai Teks',
            'deskripsi' => 'Panduan singkat menggunakan mode Zoom dan Suara di aplikasi JELAS.',
            'video' => 'https://youtube.com/watch?v=contoh',
        ], 'system');
        $this->info("Konten dibuat. ID: {$kontenId}");

        $credentialId = $serviceCredentialService->create([
            'nama_layanan' => 'Google ML Kit',
            'status' => 'aktif',
            'tanggal_diperbarui' => now()->toIso8601String(),
        ]);
        $this->info("Service credential dibuat. ID: {$credentialId}");

        return self::SUCCESS;
    }
}