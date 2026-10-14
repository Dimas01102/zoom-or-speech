<?php

namespace App\Filament\Resources;

use App\Filament\Resources\KontenResource\Pages;
use App\Models\Konten;
use App\Support\AuditLogger;
use Filament\Forms\Components\Placeholder;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables\Actions\DeleteAction;
use Filament\Tables\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Support\HtmlString;

class KontenResource extends Resource
{
    protected static ?string $model = Konten::class;

    protected static ?string $navigationIcon = 'heroicon-o-book-open';
    protected static ?string $navigationLabel = 'Konten Tutorial';
    protected static ?string $navigationGroup = 'Konten';
    protected static ?string $modelLabel = 'Konten';
    protected static ?string $pluralModelLabel = 'Konten Tutorial';
    protected static ?string $slug = 'konten';

    public static function form(Form $form): Form
    {
        return $form->schema([
            TextInput::make('judul')
                ->label('Judul')
                ->required()
                ->maxLength(255)
                ->columnSpanFull(),

            TextInput::make('video')
                ->label('Link Video')
                ->required()
                ->url()
                ->maxLength(255)
                ->columnSpanFull()
                ->helperText('Contoh: https://www.youtube.com/watch?v=xxxx'),

            Textarea::make('deskripsi')
                ->label('Deskripsi / Isi Tutorial')
                ->required()
                ->rows(12)
                ->columnSpanFull()
                ->helperText('Teks ini ditampilkan di halaman detail tutorial pada aplikasi.'),

            Placeholder::make('panduan_format')
                ->hiddenLabel()
                ->columnSpanFull()
                ->content(new HtmlString(
                    '<pre style="white-space:pre-wrap;font-size:0.8rem;line-height:1.5;margin:0;'
                    .'background:rgba(148,163,184,0.12);padding:0.75rem 1rem;border-radius:0.5rem;">'
                    .e("tags: Panduan Dasar, Mode Kamera"
                        ."\n\n"."Paragraf pengantar."
                        ."\n\n"."# Judul Bagian Langkah"
                        ."\n"."1. Judul langkah | Isi langkah"
                        ."\n\n"."# Judul Bagian Tips"
                        ."\n"."- Tips pertama")
                    .'</pre>'
                )),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->defaultSort('updated_at', 'desc')
            ->columns([
                // Kolom Nomor (Menyesuaikan dengan halaman paginasi aktif)
                TextColumn::make('no')
                    ->label('No.')
                    ->getStateUsing(function ($rowLoop, $livewire) {
                        return $rowLoop->iteration + ($livewire->getTableRecordsPerPage() * ($livewire->getTablePage() - 1));
                    }),

                TextColumn::make('judul')
                    ->label('Judul')
                    ->searchable()
                    ->wrap(),

                TextColumn::make('video')
                    ->label('Video')
                    ->limit(30)
                    ->url(fn (Konten $record): string => $record->video, shouldOpenInNewTab: true)
                    ->color('primary'),

                TextColumn::make('diperbarui_oleh')
                    ->label('Diperbarui Oleh')
                    ->toggleable(),

                TextColumn::make('updated_at')
                    ->label('Terakhir Diperbarui')
                    ->dateTime()
                    ->sortable(),
            ])
            ->actions([
                EditAction::make(),
                DeleteAction::make()
                    ->after(fn () => AuditLogger::log(null, 'konten_deleted')),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListKonten::route('/'),
            'create' => Pages\CreateKonten::route('/create'),
            'edit' => Pages\EditKonten::route('/{record}/edit'),
        ];
    }
}