<?php

namespace Tests\Feature;

use App\Filament\Pages\Auth\Login;
use App\Models\Admin;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\Hash;
use Livewire\Livewire;
use Tests\TestCase;

class LoginNotificationTest extends TestCase
{
    use DatabaseTransactions;

    private function makeAdmin(string $username, string $password): Admin
    {
        return Admin::create([
            'username' => $username,
            'password' => Hash::make($password),
        ]);
    }

    public function test_failed_login_sends_notification(): void
    {
        $this->makeAdmin('admin_uji', 'password-benar');

        Livewire::test(Login::class)
            ->fillForm([
                'username' => 'admin_uji',
                'password' => 'password-salah',
            ])
            ->call('authenticate')
            ->assertNotified('Login gagal')
            ->assertHasErrors();
    }

    public function test_failed_login_with_unknown_username_sends_notification(): void
    {
        Livewire::test(Login::class)
            ->fillForm([
                'username' => 'tidak-ada',
                'password' => 'apa-saja',
            ])
            ->call('authenticate')
            ->assertNotified('Login gagal');
    }

    public function test_successful_login_does_not_send_notification(): void
    {
        $this->makeAdmin('admin_benar', 'password-benar');

        Livewire::test(Login::class)
            ->fillForm([
                'username' => 'admin_benar',
                'password' => 'password-benar',
            ])
            ->call('authenticate')
            ->assertNotNotified('Login gagal');
    }
}
