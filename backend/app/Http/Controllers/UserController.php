<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\UserService;
use Illuminate\Http\Request;

/**
 * UC-010. Lihat, edit, hapus user (cascade hapus user_setting).
 */
class UserController extends Controller
{
    public function __construct(protected UserService $userService) {}

    public function index()
    {
        return response()->json($this->userService->all());
    }

    public function show(string $id)
    {
        $user = $this->userService->find($id);
        if (!$user) {
            return response()->json(['message' => 'Tidak ditemukan.'], 404);
        }
        return response()->json($user);
    }

    public function update(Request $request, string $id)
    {
        $data = $request->validate([
            'username' => 'sometimes|string|max:255',
            'email' => 'sometimes|email',
        ]);

        $this->userService->update($id, $data);
        return response()->json(['success' => true]);
    }

    public function destroy(string $id)
    {
        // Cascade ke user_setting sudah ditangani di dalam service.
        $this->userService->delete($id);
        return response()->json(['success' => true]);
    }
}
