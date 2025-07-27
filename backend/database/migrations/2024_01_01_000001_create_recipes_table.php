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
        Schema::create('recipes', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description')->nullable();
            $table->integer('servings')->default(1);
            $table->integer('prep_time')->nullable();
            $table->integer('cook_time')->nullable();
            $table->unsignedBigInteger('parent_recipe_id')->nullable();
            $table->enum('recipe_type', ['main', 'sauce', 'marinade', 'side', 'base'])->default('main');
            $table->timestamps();
            
            $table->foreign('parent_recipe_id')->references('id')->on('recipes')->onDelete('cascade');
            $table->index('parent_recipe_id');
            $table->index('recipe_type');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('recipes');
    }
};