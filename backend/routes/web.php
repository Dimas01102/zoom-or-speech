<?php

use Illuminate\Support\Facades\Route;

// Root langsung diarahkan ke panel admin.
// Filament otomatis membawa ke /admin/login bila belum login,
// atau ke dashboard bila sudah login.
Route::redirect('/', '/admin');
