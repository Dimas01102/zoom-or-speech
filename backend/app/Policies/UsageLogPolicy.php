<?php

namespace App\Policies;

use App\Models\Admin;
use App\Models\User;

class UsageLogPolicy
{
    public function create(User $actor): bool
    {
        return true;
    }

    public function viewAny(Admin $actor): bool
    {
        return true;
    }

    public function delete(Admin $actor): bool
    {
        return true;
    }
}
