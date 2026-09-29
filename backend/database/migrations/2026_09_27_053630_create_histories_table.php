<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('history', function (Blueprint $table) {
            $table->id('id_history');
            $table->foreignId('id_user')->constrained('user', 'id_user')->cascadeOnDelete();
            $table->timestamp('waktu_scan')->useCurrent();
            $table->enum('type', ['zoom', 'tts']);
            $table->text('teks_hasil');
            $table->longText('gambar')->nullable();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('history');
    }
};