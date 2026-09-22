<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\AdminService;
use Illuminate\Http\Request;

/**
 * UC-001 (admin). Login manual cocokkan username/password ke Firestore.
 */
class AuthController extends Controller
{
    public function __construct(protected AdminService $adminService) {}

    public function showLogin()
    {
        return view('admin.auth.login');
    }

    public function login(Request $request)
    {
        $request->validate([
            'username' => 'required|string',
            'password' => 'required|string',
        ]);

        $admin = $this->adminService->findByUsername($request->username);

        if (!$admin || !password_verify($request->password, $admin->password)) {
            return back()->withErrors(['username' => 'Username atau password salah.']);
        }

        $request->session()->put('admin_id', $admin->idAdmin);
        $request->session()->put('admin_username', $admin->username);
        $request->session()->regenerate();

        return redirect()->route('admin.dashboard');
    }

    public function logout(Request $request)
    {
        $request->session()->forget(['admin_id', 'admin_username']);
        $request->session()->regenerate();
        return redirect()->route('admin.login');
    }
}
