<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\HomePageDataController;
use Illuminate\Support\Facades\Route;

// Endpoint ini akan menerima method POST
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {

    Route::get('/homepage-data', [HomePageDataController::class, 'index']);
});
