<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user', function (Blueprint $table) {
            $table->id('id_user');
            $table->string('username');
            $table->string('email')->unique();
            $table->timestamp('tanggal_dibuat')->useCurrent();
            $table->string('firebase_uid')->unique();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user');
    }
};