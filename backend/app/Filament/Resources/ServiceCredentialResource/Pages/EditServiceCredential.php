<?php

namespace App\Filament\Resources\ServiceCredentialResource\Pages;

use App\Filament\Resources\ServiceCredentialResource;
use Filament\Resources\Pages\EditRecord;

class EditServiceCredential extends EditRecord
{
    protected static string $resource = ServiceCredentialResource::class;

    protected function getHeaderActions(): array
    {
        // Tidak ada tombol hapus, sesuai matrix.
        return [];
    }

    protected function mutateFormDataBeforeSave(array $data): array
    {
        $data['tanggal_diperbarui'] = now();
        return $data;
    }
}