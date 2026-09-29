<?php

namespace App\Models;

use Illuminate\Auth\Authenticatable;
use Illuminate\Contracts\Auth\Authenticatable as AuthenticatableContract;
use Illuminate\Database\Eloquent\Model;

class User extends Model implements AuthenticatableContract
{
    use Authenticatable;

    protected $table = 'user';
    protected $primaryKey = 'id_user';
    public $timestamps = false;

    protected $fillable = ['username', 'email', 'tanggal_dibuat', 'firebase_uid'];

    public function history()
    {
        return $this->hasMany(History::class, 'id_user', 'id_user');
    }

    public function setting()
    {
        return $this->hasOne(UserSetting::class, 'id_setting', 'id_user');
    }
}