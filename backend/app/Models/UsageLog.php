<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UsageLog extends Model
{
    protected $table = 'usage_logs';
    protected $primaryKey = 'id_usage';
    public $timestamps = false;

    protected $fillable = ['id_user', 'jenis_aktivitas', 'waktu'];

    protected $casts = [
        'waktu' => 'datetime',
    ];
}