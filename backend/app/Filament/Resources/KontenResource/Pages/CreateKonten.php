<?php

namespace App\Filament\Resources\KontenResource\Pages;

use App\Filament\Resources\KontenResource;
use App\Support\AuditLogger;
use Filament\Resources\Pages\CreateRecord;

class CreateKonten extends CreateRecord
{
    protected static string $resource = KontenResource::class;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $data['diperbarui_oleh'] = auth('admin')->user()?->username;

        return $data;
    }

    protected function afterCreate(): void
    {
        AuditLogger::log(null, 'konten_created');
    }
}
