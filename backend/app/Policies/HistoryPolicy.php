<?php

namespace App\Policies;

use App\Models\Admin;
use App\Models\History;
use App\Models\User;

class HistoryPolicy
{
    public function view(User|Admin $actor, History $history): bool
    {
        if ($actor instanceof Admin) {
            return true;
        }
        return $actor->id_user === $history->id_user;
    }

    public function create(User|Admin $actor): bool
    {
        return $actor instanceof User;
    }

    public function delete(User|Admin $actor, History $history): bool
    {
        return $actor instanceof User && $actor->id_user === $history->id_user;
    }

    public function update(User|Admin $actor, History $history): bool
    {
        // Tidak ada yang boleh update history, termasuk Admin.
        return false;
    }
}
