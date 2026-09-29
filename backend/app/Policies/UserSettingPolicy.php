<?php

namespace App\Policies;

use App\Models\Admin;
use App\Models\User;
use App\Models\UserSetting;

class UserSettingPolicy
{
    public function view(User|Admin $actor, UserSetting $setting): bool
    {
        if ($actor instanceof Admin) {
            return true;
        }
        return $actor->id_user === $setting->id_setting;
    }

    public function create(User|Admin $actor, int $targetUserId): bool
    {
        return $actor instanceof User && $actor->id_user === $targetUserId;
    }

    public function update(User|Admin $actor, UserSetting $setting): bool
    {
        if ($actor instanceof Admin) {
            return true;
        }
        return $actor->id_user === $setting->id_setting;
    }
}
