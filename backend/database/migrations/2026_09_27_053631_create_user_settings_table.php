<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_setting', function (Blueprint $table) {
            $table->unsignedBigInteger('id_setting')->primary();
            $table->foreign('id_setting')->references('id_user')->on('user')->cascadeOnDelete();
            $table->float('kecepatan_suara')->default(0.5);
            $table->string('bahasa')->default('id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_setting');
    }
};