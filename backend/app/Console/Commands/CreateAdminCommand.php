<?php

namespace App\Console\Commands;

use App\Services\AdminService;
use Illuminate\Console\Command;

/**
 * Bootstrap akun admin pertama. Dipakai sekali di awal, karena login admin
 * butuh dokumen admin yang sudah ada di Firestore.
 */
class CreateAdminCommand extends Command
{
    protected $signature = 'admin:create {username} {password}';

    protected $description = 'Bikin akun admin pertama di Firestore';

    public function handle(AdminService $adminService): int
    {
        $username = $this->argument('username');
        $password = $this->argument('password');

        if (strlen($password) < 8) {
            $this->error('Password minimal 8 karakter.');
            return self::FAILURE;
        }

        if ($adminService->findByUsername($username)) {
            $this->error('Username sudah dipakai.');
            return self::FAILURE;
        }

        $id = $adminService->create($username, $password);

        $this->info("Admin dibuat. ID: {$id}");
        return self::SUCCESS;
    }
}