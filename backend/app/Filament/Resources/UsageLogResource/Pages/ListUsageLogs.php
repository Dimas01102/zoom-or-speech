<?php

namespace App\Filament\Resources\UsageLogResource\Pages;

use App\Filament\Resources\UsageLogResource;
use Filament\Resources\Pages\ListRecords;

class ListUsageLogs extends ListRecords
{
    protected static string $resource = UsageLogResource::class;

    protected function getHeaderActions(): array
    {
        return [];
    }
}