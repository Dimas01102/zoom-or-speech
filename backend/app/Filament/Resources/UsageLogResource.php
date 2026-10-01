<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UsageLogResource\Pages;
use App\Models\UsageLog;
use Filament\Resources\Resource;
use Filament\Tables\Actions\BulkActionGroup;
use Filament\Tables\Actions\DeleteAction;
use Filament\Tables\Actions\DeleteBulkAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class UsageLogResource extends Resource
{
    protected static ?string $model = UsageLog::class;

    protected static ?string $navigationIcon = 'heroicon-o-exclamation-triangle';
    protected static ?string $navigationLabel = 'Log Aktivitas';
    protected static ?string $navigationGroup = 'Pemantauan';
    protected static ?string $modelLabel = 'Log Aktivitas';
    protected static ?string $slug = 'log-aktivitas';

    public static function table(Table $table): Table
    {
        return $table
            ->defaultSort('waktu', 'desc')
            ->columns([
                TextColumn::make('id_user')->label('ID User'),
                TextColumn::make('jenis_aktivitas')
                    ->badge()
                    ->color(fn (string $state): string => $state === 'error' ? 'danger' : 'gray'),
                TextColumn::make('waktu')->dateTime()->sortable(),
            ])
            ->filters([
                SelectFilter::make('jenis_aktivitas')
                    ->label('Jenis Aktivitas')
                    ->options([
                        'login_success' => 'Login Berhasil',
                        'login_failed' => 'Login Gagal',
                        'logout' => 'Logout',
                        'error' => 'Error',
                        'access_denied' => 'Akses Ditolak',
                        'history_created' => 'Scan Baru',
                        'history_deleted' => 'Hapus Riwayat',
                        'setting_updated' => 'Ubah Setting',
                        'user_updated' => 'Ubah User',
                        'user_deleted' => 'Hapus User',
                        'konten_created' => 'Tambah Konten',
                        'konten_updated' => 'Ubah Konten',
                        'konten_deleted' => 'Hapus Konten',
                        'credential_updated' => 'Ubah API Key',
                    ]),
            ])
            ->actions([
                DeleteAction::make(),
            ])
            ->bulkActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }

    // Tidak ada create/edit, hanya SELECT + DELETE sesuai matrix.
    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit($record): bool
    {
        return false;
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListUsageLogs::route('/'),
        ];
    }
}