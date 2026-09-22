<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\ServiceCredentialService;
use Illuminate\Http\Request;

/**
 * UC-011. CRUD metadata saja. Nilai kredensial asli di .env, tidak di sini.
 */
class ServiceCredentialController extends Controller
{
    public function __construct(protected ServiceCredentialService $service) {}

    public function index()
    {
        return response()->json($this->service->all());
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nama_layanan' => 'required|string|max:255',
            'status' => 'required|string',
        ]);
        $data['tanggal_diperbarui'] = now()->toIso8601String();

        $id = $this->service->create($data);
        return response()->json(['id' => $id], 201);
    }

    public function update(Request $request, string $id)
    {
        $data = $request->validate([
            'nama_layanan' => 'sometimes|string|max:255',
            'status' => 'sometimes|string',
        ]);
        $data['tanggal_diperbarui'] = now()->toIso8601String();

        $this->service->update($id, $data);
        return response()->json(['success' => true]);
    }

    public function destroy(string $id)
    {
        $this->service->delete($id);
        return response()->json(['success' => true]);
    }
}
