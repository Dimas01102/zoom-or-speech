<?php

namespace App\Policies;

use App\Models\Admin;
use App\Models\Konten;
use App\Models\User;

class KontenPolicy
{
    public function viewAny(User|Admin $actor): bool
    {
        return true;
    }

    public function create(User|Admin $actor): bool
    {
        return $actor instanceof Admin;
    }

    public function update(User|Admin $actor, Konten $konten): bool
    {
        return $actor instanceof Admin;
    }

    public function delete(User|Admin $actor, Konten $konten): bool
    {
        return $actor instanceof Admin;
    }
}
