<?php

namespace Database\Seeders;

use App\Models\ServiceCredential;
use Illuminate\Database\Seeder;

class ServiceCredentialSeeder extends Seeder
{
    public function run(): void
    {
        $services = [
            'Google ML Kit (OCR)',
            'Firebase Authentication',
            'flutter_tts',
        ];

        foreach ($services as $nama) {
            ServiceCredential::firstOrCreate(
                ['nama_layanan' => $nama],
                ['status' => 'aktif', 'tanggal_diperbarui' => now()],
            );
        }
    }
}