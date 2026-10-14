<?php

namespace Tests\Feature;

use App\Filament\Widgets\ScansChart;
use App\Filament\Widgets\StatsOverview;
use App\Models\Admin;
use App\Models\History;
use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Livewire\Livewire;
use Tests\TestCase;

class DashboardSmokeTest extends TestCase
{
    use DatabaseTransactions;

    private function admin(): Admin
    {
        $admin = new Admin(['username' => 'tester']);
        $admin->id_admin = 1;

        return $admin;
    }

    public function test_dashboard_page_renders_for_admin(): void
    {
        // Widget dimuat secara lazy oleh Filament, jadi kontennya tidak ada di HTML
        // awal. Konten widget diverifikasi lewat test widget di bawah.
        $this->actingAs($this->admin(), 'admin')
            ->get('/admin')
            ->assertSuccessful();
    }

    public function test_stats_overview_widget_renders(): void
    {
        $this->actingAs($this->admin(), 'admin');

        Livewire::test(StatsOverview::class)
            ->assertSuccessful()
            ->assertSee('Total Pengguna')
            ->assertSee('Total Pemindaian')
            ->assertSee('Pemindaian Zoom')
            ->assertSee('Pemindaian Suara')
            ->assertSee('Total Konten')
            ->assertSee('Log Aktivitas');
    }

    public function test_scans_chart_widget_renders(): void
    {
        $user = User::create([
            'username' => 'Budi',
            'email' => null,
            'firebase_uid' => 'uid-dash-'.uniqid(),
            'tanggal_dibuat' => now(),
        ]);

        History::create([
            'id_user' => $user->id_user,
            'waktu_scan' => now(),
            'type' => 'zoom',
            'teks_hasil' => 'contoh hasil',
            'gambar' => null,
        ]);

        $this->actingAs($this->admin(), 'admin');

        Livewire::test(ScansChart::class)->assertSuccessful();
    }
}
