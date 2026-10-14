<?php

namespace App\Filament\Widgets;

use App\Models\History;
use Filament\Widgets\ChartWidget;

class ScansChart extends ChartWidget
{
    protected static ?string $heading = 'Pemindaian 7 Hari Terakhir';

    protected static ?string $description = 'Jumlah riwayat pemindaian per hari';

    protected static ?string $maxHeight = '300px';

    protected static ?int $sort = 2;

    protected int | string | array $columnSpan = 'full';

    protected function getData(): array
    {
        $hari = collect(range(6, 0))
            ->map(fn (int $i) => now()->subDays($i)->startOfDay());

        $total = History::query()
            ->where('waktu_scan', '>=', $hari->first())
            ->selectRaw('DATE(waktu_scan) as tanggal, COUNT(*) as jumlah')
            ->groupByRaw('DATE(waktu_scan)')
            ->get()
            ->mapWithKeys(fn ($row): array => [(string) $row->tanggal => (int) $row->jumlah]);

        return [
            'datasets' => [
                [
                    'label' => 'Jumlah Pemindaian',
                    'data' => $hari
                        ->map(fn ($tanggal): int => $total[$tanggal->toDateString()] ?? 0)
                        ->all(),
                    'borderColor' => '#f97316',
                    'backgroundColor' => 'rgba(249, 115, 22, 0.15)',
                    'fill' => true,
                    'tension' => 0.35,
                ],
            ],
            'labels' => $hari
                ->map(fn ($tanggal): string => $tanggal->locale('id')->translatedFormat('d M'))
                ->all(),
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}
