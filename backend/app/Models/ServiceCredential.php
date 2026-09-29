<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ServiceCredential extends Model
{
    protected $table = 'service_credentials';
    protected $primaryKey = 'id_service';
    public $timestamps = false;

    protected $fillable = ['nama_layanan', 'status', 'tanggal_diperbarui'];
}