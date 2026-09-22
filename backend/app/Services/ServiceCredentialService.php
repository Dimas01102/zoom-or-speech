<?php

namespace App\Services;

use App\Models\ServiceCredentialModel;
use Kreait\Firebase\Contract\Firestore;

/**
 * UC-011. CRUD metadata service_credentials. Nilai kredensial asli TIDAK
 * PERNAH disimpan di sini, hanya di .env Laravel.
 */
class ServiceCredentialService
{
    protected $collection;

    public function __construct(protected Firestore $firestore)
    {
        $this->collection = $firestore->database()->collection('service_credentials');
    }

    public function all(): array
    {
        $result = [];
        foreach ($this->collection->documents() as $doc) {
            if ($doc->exists()) {
                $result[] = ServiceCredentialModel::fromFirestore($doc->id(), $doc->data());
            }
        }
        return $result;
    }

    public function create(array $data): string
    {
        $ref = $this->collection->newDocument();
        $ref->set($data);
        return $ref->id();
    }

    public function update(string $id, array $data): void
    {
        $this->collection->document($id)->set($data, ['merge' => true]);
    }

    public function delete(string $id): void
    {
        $this->collection->document($id)->delete();
    }
}
