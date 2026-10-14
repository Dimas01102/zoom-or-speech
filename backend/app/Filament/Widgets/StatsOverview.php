<?php

namespace App\Filament\Widgets;

use App\Models\History;
use App\Models\Konten;
use App\Models\UsageLog;
use App\Models\User;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends BaseWidget
{
    protected static ?int $sort = 1;

    protected function getStats(): array
    {
        return [
            Stat::make('Total Pengguna', User::count())
                ->description('Pengguna terdaftar')
                ->descriptionIcon('heroicon-m-users')
                ->color('primary')
                ->icon('heroicon-o-users'),
            Stat::make('Total Pemindaian', History::count())
                ->description('Seluruh riwayat pemindaian')
                ->descriptionIcon('heroicon-m-clipboard-document-check')
                ->color('info')
                ->icon('heroicon-o-document-magnifying-glass'),
            Stat::make('Pemindaian Zoom', History::where('type', 'zoom')->count())
                ->description('Mode OCR (Zoom)')
                ->color('warning')
                ->icon('heroicon-o-magnifying-glass-plus'),
            Stat::make('Pemindaian Suara', History::where('type', 'tts')->count())
                ->description('Mode TTS (Suara)')
                ->color('success')
                ->icon('heroicon-o-speaker-wave'),
            Stat::make('Total Konten', Konten::count())
                ->description('Materi tutorial')
                ->color('primary')
                ->icon('heroicon-o-book-open'),
            Stat::make('Log Aktivitas', UsageLog::count())
                ->description('Aktivitas tercatat')
                ->color('gray')
                ->icon('heroicon-o-clipboard-document-list'),
        ];
    }
}
