<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\History;

class HistoryMonitorController extends Controller
{
    public function index()
    {
        return response()->json(History::all());
    }

    public function forUser(int $userId)
    {
        return response()->json(History::where('id_user', $userId)->get());
    }
}