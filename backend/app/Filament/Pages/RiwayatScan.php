<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;

class RiwayatScan extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-clock';

    protected static ?string $navigationLabel = 'Riwayat Scan';

    protected static ?string $navigationGroup = 'Pemantauan';

    protected static string $view = 'filament.pages.riwayat-scan';
}