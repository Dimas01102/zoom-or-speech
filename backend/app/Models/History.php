<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class History extends Model
{
    protected $table = 'history';
    protected $primaryKey = 'id_history';
    public $timestamps = false;

    protected $fillable = ['id_user', 'waktu_scan', 'type', 'teks_hasil', 'gambar'];

    public function user()
    {
        return $this->belongsTo(User::class, 'id_user', 'id_user');
    }
}