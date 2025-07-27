<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('favorite_ingredients', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('default_unit', 50)->nullable();
            $table->integer('usage_count')->default(1);
            $table->timestamps();
            
            $table->index('name');
            $table->index('usage_count');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('favorite_ingredients');
    }
};