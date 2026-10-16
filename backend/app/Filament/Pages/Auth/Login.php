<?php

namespace App\Filament\Pages\Auth;

use Filament\Forms\Components\Component;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Pages\Auth\Login as BaseLogin;

class Login extends BaseLogin
{
    protected function getEmailFormComponent(): Component
    {
        return TextInput::make('username')
            ->label('Username')
            ->required()
            ->autocomplete()
            ->autofocus()
            ->extraInputAttributes(['tabindex' => 1]);
    }

    protected function getCredentialsFromFormData(array $data): array
    {
        return [
            'username' => $data['username'],
            'password' => $data['password'],
        ];
    }

    /**
     * Tampilkan notifikasi saat login gagal (username / password salah),
     * lalu tetap lempar validation error bawaan Filament.
     */
    protected function throwFailureValidationException(): never
    {
        Notification::make()
            ->title('Login gagal')
            ->body('Username atau password yang Anda masukkan salah.')
            ->danger()
            ->send();

        parent::throwFailureValidationException();
    }
}