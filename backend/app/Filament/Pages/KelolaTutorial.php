<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;

class KelolaTutorial extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-book-open';

    protected static ?string $navigationLabel = 'Kelola Tutorial';

    protected static ?string $navigationGroup = 'Konten';

    protected static string $view = 'filament.pages.kelola-tutorial';
}