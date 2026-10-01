<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UserSettingResource\Pages;
use App\Models\UserSetting;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class UserSettingResource extends Resource
{
    protected static ?string $model = UserSetting::class;

    protected static ?string $navigationIcon = 'heroicon-o-adjustments-horizontal';
    protected static ?string $navigationLabel = 'Pengaturan User';
    protected static ?string $navigationGroup = 'Pengguna';
    protected static ?string $modelLabel = 'Pengaturan User';
    protected static ?string $slug = 'pengaturan-user';

    public static function form(Form $form): Form
    {
        return $form->schema([
            Select::make('bahasa')
                ->options(['id' => 'Indonesia', 'en' => 'Inggris'])
                ->required(),
            TextInput::make('kecepatan_suara')
                ->numeric()
                ->minValue(0.25)
                ->maxValue(1.0)
                ->step(0.05)
                ->required(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('user.username')->label('User')->searchable(),
                TextColumn::make('bahasa'),
                TextColumn::make('kecepatan_suara')->label('Kecepatan Suara'),
            ])
            ->actions([
                EditAction::make(),
            ]);
    }

    // Tidak ada create/delete, hanya SELECT + UPDATE sesuai matrix.
    public static function canCreate(): bool
    {
        return false;
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListUserSettings::route('/'),
            'edit' => Pages\EditUserSetting::route('/{record}/edit'),
        ];
    }
}