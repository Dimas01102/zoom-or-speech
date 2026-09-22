<?php

namespace App\Services;

use App\Models\KontenModel;
use Kreait\Firebase\Contract\Firestore;

/**
 * UC-008. CRUD konten tutorial (judul, deskripsi, video).
 */
class KontenService
{
    protected $collection;

    public function __construct(protected Firestore $firestore)
    {
        $this->collection = $firestore->database()->collection('konten');
    }

    public function all(): array
    {
        $result = [];
        foreach ($this->collection->documents() as $doc) {
            if ($doc->exists()) {
                $result[] = KontenModel::fromFirestore($doc->id(), $doc->data());
            }
        }
        return $result;
    }

    public function find(string $id): ?KontenModel
    {
        $doc = $this->collection->document($id)->snapshot();
        return $doc->exists() ? KontenModel::fromFirestore($doc->id(), $doc->data()) : null;
    }

    public function create(array $data, string $adminUsername): string
    {
        $data['diperbarui_oleh'] = $adminUsername;
        $ref = $this->collection->newDocument();
        $ref->set($data);
        return $ref->id();
    }

    public function update(string $id, array $data, string $adminUsername): void
    {
        $data['diperbarui_oleh'] = $adminUsername;
        $this->collection->document($id)->set($data, ['merge' => true]);
    }

    public function delete(string $id): void
    {
        $this->collection->document($id)->delete();
    }
}
