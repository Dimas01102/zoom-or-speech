<?php

namespace App\Filament\Resources\AdminResource\Pages;

use App\Filament\Resources\AdminResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditAdmin extends EditRecord
{
    protected static string $resource = AdminResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make()
                ->after(function ($record) {
                    if ((string) auth('admin')->id() === (string) $record->getKey()) {
                        /** @var \Illuminate\Contracts\Auth\StatefulGuard $guard */
                        $guard = auth('admin');
                        $guard->logout();
                    }
                }),
        ];
    }
}