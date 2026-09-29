<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;

class KelolaUser extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-users';

    protected static ?string $navigationLabel = 'Kelola User';

    protected static ?string $navigationGroup = 'Pengguna';

    protected static string $view = 'filament.pages.kelola-user';
}