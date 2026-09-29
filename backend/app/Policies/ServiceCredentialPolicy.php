<?php

namespace App\Policies;

use App\Models\Admin;
use App\Models\ServiceCredential;

class ServiceCredentialPolicy
{
    public function viewAny(Admin $actor): bool
    {
        return true;
    }

    public function update(Admin $actor, ServiceCredential $credential): bool
    {
        return true;
    }
}
