<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;

class ManajemenAdmin extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-shield-check';

    protected static ?string $navigationLabel = 'Manajemen Admin';

    protected static ?string $navigationGroup = 'Sistem';

    protected static string $view = 'filament.pages.manajemen-admin';
}