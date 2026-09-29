<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserSetting extends Model
{
    protected $table = 'user_setting';
    protected $primaryKey = 'id_setting';
    public $incrementing = false;
    public $timestamps = false;

    protected $fillable = ['id_setting', 'kecepatan_suara', 'bahasa'];

    public function user()
    {
        return $this->belongsTo(User::class, 'id_setting', 'id_user');
    }
}