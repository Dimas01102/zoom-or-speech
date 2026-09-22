<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\AdminService;
use Illuminate\Http\Request;

/**
 * UC-013. CRUD akun admin. Tolak hapus kalau satu-satunya akun tersisa.
 * Hapus akun sendiri sambil admin lain masih ada, paksa logout.
 */
class AdminController extends Controller
{
    public function __construct(protected AdminService $adminService) {}

    public function index()
    {
        return response()->json($this->adminService->all());
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'username' => 'required|string|max:255',
            'password' => 'required|string|min:8',
        ]);

        $id = $this->adminService->create($data['username'], $data['password']);
        return response()->json(['id' => $id], 201);
    }

    public function update(Request $request, string $id)
    {
        $data = $request->validate([
            'username' => 'sometimes|string|max:255',
            'password' => 'sometimes|string|min:8',
        ]);

        $this->adminService->update($id, $data);
        return response()->json(['success' => true]);
    }

    public function destroy(Request $request, string $id)
    {
        $deletingSelf = $request->session()->get('admin_id') === $id;

        $deleted = $this->adminService->delete($id);

        if (!$deleted) {
            return response()->json([
                'message' => 'Tidak bisa hapus, ini satu-satunya akun admin.',
            ], 422);
        }

        if ($deletingSelf) {
            $request->session()->forget(['admin_id', 'admin_username']);
            $request->session()->regenerate();
            return response()->json(['success' => true, 'force_logout' => true]);
        }

        return response()->json(['success' => true, 'force_logout' => false]);
    }
}
