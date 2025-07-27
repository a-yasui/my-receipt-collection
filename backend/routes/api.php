<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// Health check endpoint
Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'timestamp' => now()->toIso8601String(),
    ]);
});

// Recipe routes
Route::prefix('recipes')->group(function () {
    Route::get('/', function () {
        return response()->json(['message' => 'Recipe list endpoint']);
    });
    Route::post('/', function () {
        return response()->json(['message' => 'Create recipe endpoint']);
    });
    Route::get('/{id}', function ($id) {
        return response()->json(['message' => 'Get recipe endpoint', 'id' => $id]);
    });
    Route::put('/{id}', function ($id) {
        return response()->json(['message' => 'Update recipe endpoint', 'id' => $id]);
    });
    Route::delete('/{id}', function ($id) {
        return response()->json(['message' => 'Delete recipe endpoint', 'id' => $id]);
    });
});

// Ingredient routes
Route::prefix('ingredients')->group(function () {
    Route::get('/favorites', function () {
        return response()->json(['message' => 'Favorite ingredients endpoint']);
    });
    Route::post('/favorites', function () {
        return response()->json(['message' => 'Add favorite ingredient endpoint']);
    });
});

// Tag routes
Route::prefix('tags')->group(function () {
    Route::get('/', function () {
        return response()->json(['message' => 'Tag list endpoint']);
    });
    Route::post('/', function () {
        return response()->json(['message' => 'Create tag endpoint']);
    });
});

// Search route
Route::get('/search', function (Request $request) {
    return response()->json(['message' => 'Search endpoint', 'query' => $request->query('q')]);
});