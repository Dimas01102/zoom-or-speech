<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Konten;
use App\Support\AuditLogger;
use Illuminate\Http\Request;

class TutorialController extends Controller
{
    public function index()
    {
        $this->authorize('viewAny', Konten::class);
        return response()->json(Konten::all());
    }

    public function store(Request $request)
    {
        $this->authorize('create', Konten::class);

        $data = $request->validate([
            'judul' => 'required|string|max:255',
            'deskripsi' => 'required|string',
            'video' => 'required|url',
        ]);
        $data['diperbarui_oleh'] = auth('admin')->user()->username;

        $konten = Konten::create($data);
        AuditLogger::log(null, 'konten_created');

        return response()->json($konten, 201);
    }

    public function update(Request $request, Konten $konten)
    {
        $this->authorize('update', $konten);

        $data = $request->validate([
            'judul' => 'sometimes|string|max:255',
            'deskripsi' => 'sometimes|string',
            'video' => 'sometimes|url',
        ]);
        $data['diperbarui_oleh'] = auth('admin')->user()->username;

        $konten->update($data);
        AuditLogger::log(null, 'konten_updated');

        return response()->json(['success' => true]);
    }

    public function destroy(Konten $konten)
    {
        $this->authorize('delete', $konten);

        $konten->delete();
        AuditLogger::log(null, 'konten_deleted');

        return response()->json(['success' => true]);
    }
}