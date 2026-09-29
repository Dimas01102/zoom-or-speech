<?php

namespace App\Models;

use Filament\Models\Contracts\FilamentUser;
use Filament\Models\Contracts\HasName;
use Filament\Panel;
use Illuminate\Auth\Authenticatable;
use Illuminate\Contracts\Auth\Authenticatable as AuthenticatableContract;
use Illuminate\Database\Eloquent\Model;

class Admin extends Model implements AuthenticatableContract, FilamentUser, HasName
{
    use Authenticatable;

    protected $table = 'admin';
    protected $primaryKey = 'id_admin';

    protected $fillable = ['username', 'password'];
    protected $hidden = ['password'];

    public function canAccessPanel(Panel $panel): bool
    {
        return true;
    }

    public function getFilamentName(): string
    {
        return $this->username;
    }

    // Tabel admin tidak punya kolom remember_token.
    public function getRememberTokenName(): string
    {
        return '';
    }
}