<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\ServiceCredential;
use App\Support\AuditLogger;
use Illuminate\Http\Request;

class ServiceCredentialController extends Controller
{
    public function index()
    {
        $this->authorize('viewAny', ServiceCredential::class);
        return response()->json(ServiceCredential::all());
    }

    public function store(Request $request)
    {
        $this->authorize('viewAny', ServiceCredential::class);

        $data = $request->validate([
            'nama_layanan' => 'required|string|max:255',
            'status' => 'required|string',
        ]);
        $data['tanggal_diperbarui'] = now();

        $credential = ServiceCredential::create($data);
        AuditLogger::log(null, 'credential_updated');

        return response()->json($credential, 201);
    }

    public function update(Request $request, ServiceCredential $serviceCredential)
    {
        $this->authorize('update', $serviceCredential);

        $data = $request->validate([
            'nama_layanan' => 'sometimes|string|max:255',
            'status' => 'sometimes|string',
        ]);
        $data['tanggal_diperbarui'] = now();

        $serviceCredential->update($data);
        AuditLogger::log(null, 'credential_updated');

        return response()->json(['success' => true]);
    }

    public function destroy(ServiceCredential $serviceCredential)
    {
        $this->authorize('update', $serviceCredential);
        $serviceCredential->delete();
        AuditLogger::log(null, 'credential_updated');

        return response()->json(['success' => true]);
    }
}