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
        Schema::create('ingredients', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('recipe_id');
            $table->string('name');
            $table->decimal('amount', 8, 2)->nullable();
            $table->string('unit', 50)->nullable();
            $table->integer('order_index')->default(0);
            $table->unsignedBigInteger('sub_recipe_id')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
            
            $table->foreign('recipe_id')->references('id')->on('recipes')->onDelete('cascade');
            $table->foreign('sub_recipe_id')->references('id')->on('recipes')->onDelete('set null');
            $table->index('recipe_id');
            $table->index('sub_recipe_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ingredients');
    }
};