<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use Illuminate\Contracts\Auth\StatefulGuard;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function index()
    {
        $this->authorize('viewAny', Admin::class);
        return response()->json(Admin::all(['id_admin', 'username']));
    }

    public function store(Request $request)
    {
        $this->authorize('create', Admin::class);

        $data = $request->validate([
            'username' => 'required|string|max:255|unique:admin,username',
            'password' => 'required|string|min:8',
        ]);
        $data['password'] = bcrypt($data['password']);

        $admin = Admin::create($data);
        return response()->json(['id_admin' => $admin->id_admin], 201);
    }

    public function update(Request $request, Admin $admin)
    {
        $this->authorize('update', $admin);

        $data = $request->validate([
            'username' => 'sometimes|string|max:255',
            'password' => 'sometimes|string|min:8',
        ]);
        if (isset($data['password'])) {
            $data['password'] = bcrypt($data['password']);
        }

        $admin->update($data);
        return response()->json(['success' => true]);
    }

    public function destroy(Request $request, Admin $admin)
    {
        $this->authorize('delete', $admin);

        /** @var StatefulGuard $guard */
        $guard = auth('admin');

        $deletingSelf = $guard->id() === $admin->id_admin;
        $admin->delete();

        if ($deletingSelf) {
            $guard->logout();
            $request->session()->invalidate();
            return response()->json(['success' => true, 'force_logout' => true]);
        }

        return response()->json(['success' => true, 'force_logout' => false]);
    }
}