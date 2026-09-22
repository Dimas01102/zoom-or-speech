<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\KontenService;
use Illuminate\Http\Request;

/**
 * UC-008. CRUD konten tutorial.
 */
class TutorialController extends Controller
{
    public function __construct(protected KontenService $kontenService) {}

    public function index()
    {
        return response()->json($this->kontenService->all());
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'judul' => 'required|string|max:255',
            'deskripsi' => 'required|string',
            'video' => 'required|url',
        ]);

        $id = $this->kontenService->create($data, session('admin_username'));
        return response()->json(['id' => $id], 201);
    }

    public function update(Request $request, string $id)
    {
        $data = $request->validate([
            'judul' => 'sometimes|string|max:255',
            'deskripsi' => 'sometimes|string',
            'video' => 'sometimes|url',
        ]);

        $this->kontenService->update($id, $data, session('admin_username'));
        return response()->json(['success' => true]);
    }

    public function destroy(string $id)
    {
        $this->kontenService->delete($id);
        return response()->json(['success' => true]);
    }
}
