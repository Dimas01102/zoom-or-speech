<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;

class ApiKey extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-key';

    protected static ?string $navigationLabel = 'API Key';

    protected static ?string $navigationGroup = 'Sistem';

    protected static string $view = 'filament.pages.api-key';
}