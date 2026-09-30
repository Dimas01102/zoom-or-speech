<?php

namespace App\Filament\Resources;

use App\Filament\Resources\AdminResource\Pages;
use App\Models\Admin;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables\Actions\DeleteAction;
use Filament\Tables\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class AdminResource extends Resource
{
    protected static ?string $model = Admin::class;

    protected static ?string $navigationIcon = 'heroicon-o-shield-check';
    protected static ?string $navigationLabel = 'Manajemen Admin';
    protected static ?string $navigationGroup = 'Sistem';
    protected static ?string $modelLabel = 'Admin';
    protected static ?string $slug = 'manajemen-admin';

    public static function form(Form $form): Form
    {
        return $form->schema([
            TextInput::make('username')
                ->required()
                ->maxLength(255)
                ->unique(ignoreRecord: true),
            TextInput::make('password')
                ->password()
                ->revealable()
                ->required(fn (string $context): bool => $context === 'create')
                ->minLength(8)
                ->dehydrated(fn ($state) => filled($state))
                ->dehydrateStateUsing(fn ($state) => bcrypt($state))
                ->helperText('Kosongkan kalau tidak mau ganti password.'),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('username')->searchable(),
                TextColumn::make('created_at')->label('Dibuat')->dateTime()->sortable(),
            ])
            ->actions([
                EditAction::make(),
                DeleteAction::make()
                    // Sesuai instruksi: hapus akun sendiri, admin lain
                    // masih ada -> paksa logout. AdminPolicy@delete yang
                    // menolak kalau ini satu-satunya admin tersisa.
                    ->after(function ($record) {
                        if ((string) auth('admin')->id() === (string) $record->getKey()) {
                            /** @var \Illuminate\Contracts\Auth\StatefulGuard $guard */
                            $guard = auth('admin');
                            $guard->logout();
                        }
                    }),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListAdmins::route('/'),
            'create' => Pages\CreateAdmin::route('/create'),
            'edit' => Pages\EditAdmin::route('/{record}/edit'),
        ];
    }
}