<?php

namespace App\Filament\Resources;

use App\Filament\Resources\HistoryResource\Pages;
use App\Models\History;
use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\Section;
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Infolist;
use Filament\Resources\Resource;
use Filament\Tables\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class HistoryResource extends Resource
{
    protected static ?string $model = History::class;

    protected static ?string $navigationIcon = 'heroicon-o-clock';
    protected static ?string $navigationLabel = 'Riwayat Pemindaian';
    protected static ?string $navigationGroup = 'Pemantauan';
    protected static ?string $modelLabel = 'Riwayat';
    protected static ?string $pluralModelLabel = 'Riwayat Pemindaian';
    protected static ?string $slug = 'riwayat';

    public static function infolist(Infolist $infolist): Infolist
    {
        return $infolist->schema([
            Section::make('Informasi Pemindaian')
                ->columns(2)
                ->schema([
                    TextEntry::make('id_history')->label('ID'),
                    TextEntry::make('type')
                        ->label('Tipe')
                        ->badge()
                        ->formatStateUsing(fn (string $state): string => $state === 'zoom' ? 'Zoom' : 'Suara')
                        ->color(fn (string $state): string => $state === 'zoom' ? 'info' : 'success'),
                    TextEntry::make('user.username')
                        ->label('User')
                        ->placeholder('-'),
                    TextEntry::make('user.email')
                        ->label('Email')
                        ->placeholder('-'),
                    TextEntry::make('waktu_scan')
                        ->label('Waktu Scan')
                        ->dateTime(),
                ]),
            Section::make('Hasil Pemindaian')
                ->schema([
                    TextEntry::make('teks_hasil')
                        ->label('Teks Hasil OCR')
                        ->placeholder('Tidak ada teks terdeteksi.')
                        ->prose(),
                    ImageEntry::make('gambar')
                        ->label('Gambar Hasil Scan')
                        // gambar disimpan mobile sebagai base64 JPEG mentah.
                        ->state(fn (History $record): ?string => filled($record->gambar)
                            ? 'data:image/jpeg;base64,' . $record->gambar
                            : null)
                        ->visible(fn (History $record): bool => filled($record->gambar))
                        ->height(260),
                ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->defaultSort('waktu_scan', 'desc')
            ->columns([
                TextColumn::make('id_history')
                    ->label('ID')
                    ->sortable(),
                TextColumn::make('user.username')
                    ->label('User')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('type')
                    ->label('Tipe')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => $state === 'zoom' ? 'Zoom' : 'Suara')
                    ->color(fn (string $state): string => $state === 'zoom' ? 'info' : 'success'),
                TextColumn::make('teks_hasil')
                    ->label('Teks Hasil')
                    ->limit(50)
                    ->wrap()
                    ->searchable(),
                TextColumn::make('waktu_scan')
                    ->label('Waktu Scan')
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([
                SelectFilter::make('type')
                    ->label('Tipe')
                    ->options(['zoom' => 'Zoom', 'tts' => 'Suara']),
                SelectFilter::make('id_user')
                    ->label('User')
                    ->relationship('user', 'username')
                    ->searchable()
                    ->preload(),
            ])
            ->actions([
                ViewAction::make()->label('Lihat'),
            ]);
    }

    // Riwayat hanya untuk dipantau: Admin tidak boleh tambah/ubah/hapus.
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
            'index' => Pages\ListHistories::route('/'),
        ];
    }
}
