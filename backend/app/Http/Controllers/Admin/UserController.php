<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Support\AuditLogger;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function index()
    {
        return response()->json(User::all());
    }

    public function show(User $user)
    {
        $this->authorize('view', $user);
        return response()->json($user);
    }

    public function update(Request $request, User $user)
    {
        $this->authorize('update', $user);

        $data = $request->validate([
            'username' => 'sometimes|string|max:255',
            'email' => 'sometimes|email',
        ]);

        $user->update($data);
        AuditLogger::log($user->id_user, 'user_updated');

        return response()->json(['success' => true]);
    }

    public function destroy(User $user)
    {
        $this->authorize('delete', $user);

        $userId = $user->id_user;
        // Cascade ke user_setting lewat FK cascadeOnDelete di migration.
        $user->delete();
        AuditLogger::log($userId, 'user_deleted');

        return response()->json(['success' => true]);
    }
}