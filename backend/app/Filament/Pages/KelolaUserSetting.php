<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;

class KelolaUserSetting extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-adjustments-horizontal';

    protected static ?string $navigationLabel = 'Pengaturan User';

    protected static ?string $navigationGroup = 'Pengguna';

    protected static string $view = 'filament.pages.kelola-user-setting';
}