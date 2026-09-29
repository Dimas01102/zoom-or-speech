<?php

namespace App\Policies;

use App\Models\Admin;

class AdminPolicy
{
    public function viewAny(Admin $actor): bool
    {
        return true;
    }

    public function create(Admin $actor): bool
    {
        return true;
    }

    public function update(Admin $actor, Admin $target): bool
    {
        return true;
    }

    public function delete(Admin $actor, Admin $target): bool
    {
        return Admin::count() > 1;
    }
}
