<?php

namespace Tests\Feature;

use App\Filament\Resources\HistoryResource\Pages\ListHistories;
use App\Models\Admin;
use App\Models\History;
use App\Models\User;
use Filament\Tables\Actions\ViewAction;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Livewire\Livewire;
use Tests\TestCase;

class HistoryResourceSmokeTest extends TestCase
{
    use DatabaseTransactions;

    private function admin(): Admin
    {
        $admin = new Admin(['username' => 'tester']);
        $admin->id_admin = 1;

        return $admin;
    }

    public function test_admin_can_open_history_resource_index(): void
    {
        $this->actingAs($this->admin(), 'admin')
            ->get('/admin/riwayat')
            ->assertSuccessful();
    }

    public function test_view_action_renders_history_detail(): void
    {
        $user = User::create([
            'username' => 'Budi',
            'email' => null,
            'firebase_uid' => 'uid-smoke-'.uniqid(),
            'tanggal_dibuat' => now(),
        ]);

        $history = History::create([
            'id_user' => $user->id_user,
            'waktu_scan' => now(),
            'type' => 'zoom',
            'teks_hasil' => 'Contoh teks hasil pemindaian',
            'gambar' => base64_encode('dummy-image'),
        ]);

        $this->actingAs($this->admin(), 'admin');

        Livewire::test(ListHistories::class)
            ->mountTableAction(ViewAction::class, $history)
            ->assertSuccessful()
            ->assertSee('Contoh teks hasil pemindaian');
    }
}
