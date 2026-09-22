<?php

namespace App\Services;

use App\Models\UserModel;
use Kreait\Firebase\Contract\Firestore;

/**
 * UC-010. Admin: read, update, delete user (cascade hapus user_setting).
 */
class UserService
{
    protected $collection;

    public function __construct(protected Firestore $firestore, protected UserSettingService $userSettingService)
    {
        $this->collection = $firestore->database()->collection('user');
    }

    public function all(): array
    {
        $result = [];
        foreach ($this->collection->documents() as $doc) {
            if ($doc->exists()) {
                $result[] = UserModel::fromFirestore($doc->id(), $doc->data());
            }
        }
        return $result;
    }

    public function find(string $id): ?UserModel
    {
        $doc = $this->collection->document($id)->snapshot();
        return $doc->exists() ? UserModel::fromFirestore($doc->id(), $doc->data()) : null;
    }

    public function update(string $id, array $data): void
    {
        $this->collection->document($id)->set($data, ['merge' => true]);
    }

    public function delete(string $id): void
    {
        $this->collection->document($id)->delete();
        // Cascade wajib, sesuai instruksi awal.
        $this->userSettingService->delete($id);
    }
}
