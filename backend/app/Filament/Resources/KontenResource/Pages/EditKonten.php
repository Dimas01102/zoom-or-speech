<?php

namespace App\Filament\Resources\KontenResource\Pages;

use App\Filament\Resources\KontenResource;
use App\Support\AuditLogger;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditKonten extends EditRecord
{
    protected static string $resource = KontenResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make()
                ->after(fn () => AuditLogger::log(null, 'konten_deleted')),
        ];
    }

    protected function mutateFormDataBeforeSave(array $data): array
    {
        $data['diperbarui_oleh'] = auth('admin')->user()?->username;

        return $data;
    }

    protected function afterSave(): void
    {
        AuditLogger::log(null, 'konten_updated');
    }
}
