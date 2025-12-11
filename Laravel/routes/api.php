<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Support\Facades\Route;

// Endpoint ini akan menerima method POST
Route::post('/login', [AuthController::class, 'login']);