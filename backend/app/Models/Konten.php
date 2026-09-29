<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Konten extends Model
{
    protected $table = 'konten';
    protected $primaryKey = 'id_konten';

    protected $fillable = ['judul', 'deskripsi', 'video', 'diperbarui_oleh'];
}