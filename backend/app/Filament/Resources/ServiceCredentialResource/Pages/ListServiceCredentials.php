<?php

namespace App\Filament\Resources\ServiceCredentialResource\Pages;

use App\Filament\Resources\ServiceCredentialResource;
use Filament\Resources\Pages\ListRecords;

class ListServiceCredentials extends ListRecords
{
    protected static string $resource = ServiceCredentialResource::class;

    protected function getHeaderActions(): array
    {
        return [];
    }
}