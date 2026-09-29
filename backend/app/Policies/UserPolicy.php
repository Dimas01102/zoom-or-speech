<?php

namespace App\Policies;

use App\Models\Admin;
use App\Models\User;

class UserPolicy
{
    public function view(User|Admin $actor, User $target): bool
    {
        if ($actor instanceof Admin) {
            return true;
        }
        return $actor->id_user === $target->id_user;
    }

    public function update(User|Admin $actor, User $target): bool
    {
        return $actor instanceof Admin;
    }

    public function delete(User|Admin $actor, User $target): bool
    {
        return $actor instanceof Admin;
    }
}
