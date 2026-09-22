<?php

namespace App\Services;

use App\Models\AdminModel;
use Kreait\Firebase\Contract\Firestore;

/**
 * UC-001 (bagian admin) dan UC-013. Login manual via Firestore, bukan
 * Eloquent, karena tidak ada tabel SQL.
 */
class AdminService
{
    protected $collection;

    public function __construct(protected Firestore $firestore)
    {
        $this->collection = $firestore->database()->collection('admin');
    }

    public function count(): int
    {
        return count(iterator_to_array($this->collection->documents()));
    }

    public function all(): array
    {
        $result = [];
        foreach ($this->collection->documents() as $doc) {
            if ($doc->exists()) {
                $result[] = AdminModel::fromFirestore($doc->id(), $doc->data());
            }
        }
        return $result;
    }

    public function findByUsername(string $username): ?AdminModel
    {
        $query = $this->collection->where('username', '=', $username)->limit(1);
        foreach ($query->documents() as $doc) {
            if ($doc->exists()) {
                return AdminModel::fromFirestore($doc->id(), $doc->data());
            }
        }
        return null;
    }

    public function find(string $id): ?AdminModel
    {
        $doc = $this->collection->document($id)->snapshot();
        return $doc->exists() ? AdminModel::fromFirestore($doc->id(), $doc->data()) : null;
    }

    public function create(string $username, string $plainPassword): string
    {
        $ref = $this->collection->newDocument();
        $ref->set([
            'username' => $username,
            'password' => bcrypt($plainPassword),
        ]);
        return $ref->id();
    }

    public function update(string $id, array $data): void
    {
        if (isset($data['password'])) {
            $data['password'] = bcrypt($data['password']);
        }
        $this->collection->document($id)->set($data, ['merge' => true]);
    }

    /**
     * Tolak hapus kalau ini satu-satunya akun admin tersisa.
     * Return true kalau berhasil hapus.
     */
    public function delete(string $id): bool
    {
        if ($this->count() <= 1) {
            return false;
        }
        $this->collection->document($id)->delete();
        return true;
    }
}
