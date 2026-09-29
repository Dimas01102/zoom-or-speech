<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Konten;

class KontenController extends Controller
{
    public function index()
    {
        $this->authorize('viewAny', Konten::class);
        return response()->json(Konten::all());
    }
}