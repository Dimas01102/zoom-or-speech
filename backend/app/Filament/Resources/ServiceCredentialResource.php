<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ServiceCredentialResource\Pages;
use App\Models\ServiceCredential;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class ServiceCredentialResource extends Resource
{
    protected static ?string $model = ServiceCredential::class;

    protected static ?string $navigationIcon = 'heroicon-o-key';
    protected static ?string $navigationLabel = 'API Key';
    protected static ?string $navigationGroup = 'Sistem';
    protected static ?string $modelLabel = 'Service Credential';
    protected static ?string $slug = 'api-key';

    public static function form(Form $form): Form
    {
        return $form->schema([
            TextInput::make('nama_layanan')
                ->label('Nama Layanan')
                ->required()
                ->maxLength(255),
            Select::make('status')
                ->options([
                    'aktif' => 'Aktif',
                    'nonaktif' => 'Nonaktif',
                ])
                ->required(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('nama_layanan')->label('Nama Layanan')->searchable(),
                TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => $state === 'aktif' ? 'success' : 'danger'),
                TextColumn::make('tanggal_diperbarui')->label('Diperbarui')->dateTime()->sortable(),
            ])
            ->actions([
                EditAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListServiceCredentials::route('/'),
            'edit' => Pages\EditServiceCredential::route('/{record}/edit'),
        ];
    }

    // cuma metadata (nama_layanan, status).
    public static function canCreate(): bool
    {
        return false;
    }
}