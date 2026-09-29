<?php

namespace Database\Seeders;

use App\Models\Konten;
use Illuminate\Database\Seeder;

class KontenSeeder extends Seeder
{
    public function run(): void
    {
        $video = 'https://www.youtube.com/';

        $items = [
            [
                'judul' => 'Cara Memindai Teks',
                'deskripsi' => 'Pelajari cara menangkap dokumen fisik, buku, kemasan obat, atau petunjuk ruangan dengan kamera HP Anda untuk langsung diubah menjadi suara atau tulisan berukuran besar.',
            ],
            [
                'judul' => 'Menggunakan Mode Zoom',
                'deskripsi' => 'Tampilkan hasil pindaian sebagai teks berukuran besar dengan kontras tinggi, sehingga mudah dibaca tanpa perlu memicingkan mata.',
            ],
            [
                'judul' => 'Menggunakan Mode Suara',
                'deskripsi' => 'Dengarkan hasil pindaian dibacakan otomatis. Anda bisa mengulang, menjeda, atau memutar kembali kapan saja.',
            ],
            [
                'judul' => 'Mengatur Kecepatan Suara dan Bahasa',
                'deskripsi' => 'Sesuaikan kecepatan bacaan dan pilih bahasa Indonesia atau Inggris lewat menu Pengaturan agar suara terdengar nyaman.',
            ],
            [
                'judul' => 'Melihat dan Menghapus Riwayat',
                'deskripsi' => 'Buka kembali hasil pindaian sebelumnya di menu Riwayat. Geser ke kiri untuk menghapus satu, atau pilih beberapa sekaligus.',
            ],
        ];

        foreach ($items as $item) {
            Konten::updateOrCreate(
                ['judul' => $item['judul']],
                [
                    'deskripsi' => $item['deskripsi'],
                    'video' => $video,
                    'diperbarui_oleh' => 'admin',
                ],
            );
        }
    }
}