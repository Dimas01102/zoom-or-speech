<?php

namespace App\Services;

use App\Models\UserSettingModel;
use Kreait\Firebase\Contract\Firestore;

/**
 * UC-009. Admin lihat dan edit user_setting milik user manapun.
 * ID dokumen = id_user (1-1).
 */
class UserSettingService
{
    protected $collection;

    public function __construct(protected Firestore $firestore)
    {
        $this->collection = $firestore->database()->collection('user_setting');
    }

    public function all(): array
    {
        $result = [];
        foreach ($this->collection->documents() as $doc) {
            if ($doc->exists()) {
                $result[] = UserSettingModel::fromFirestore($doc->id(), $doc->data());
            }
        }
        return $result;
    }

    public function find(string $userId): ?UserSettingModel
    {
        $doc = $this->collection->document($userId)->snapshot();
        return $doc->exists() ? UserSettingModel::fromFirestore($doc->id(), $doc->data()) : null;
    }

    /**
     * Validasi input, tolak bahasa selain id/en, kecepatan di luar 0.25-1.0.
     */
    public function update(string $userId, array $data): array
    {
        $errors = [];

        if (isset($data['bahasa']) && !in_array($data['bahasa'], ['id', 'en'], true)) {
            $errors[] = 'Bahasa harus id atau en.';
        }
        if (isset($data['kecepatan_suara'])) {
            $rate = (float) $data['kecepatan_suara'];
            if ($rate < 0.25 || $rate > 1.0) {
                $errors[] = 'Kecepatan suara harus antara 0.25 dan 1.0.';
            }
        }

        if (!empty($errors)) {
            return ['success' => false, 'errors' => $errors];
        }

        $this->collection->document($userId)->set($data, ['merge' => true]);
        return ['success' => true, 'errors' => []];
    }

    public function delete(string $userId): void
    {
        $this->collection->document($userId)->delete();
    }
}
