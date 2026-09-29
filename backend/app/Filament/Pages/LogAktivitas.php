<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;

class LogAktivitas extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-exclamation-triangle';

    protected static ?string $navigationLabel = 'Log Aktivitas';

    protected static ?string $navigationGroup = 'Pemantauan';

    protected static string $view = 'filament.pages.log-aktivitas';
}