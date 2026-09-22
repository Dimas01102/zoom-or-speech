<?php

namespace App\Services;

use App\Models\UsageLogModel;
use Kreait\Firebase\Contract\Firestore;

/**
 * UC-012. Admin read dan delete/purge usage_logs.
 */
class UsageLogService
{
    protected $collection;

    public function __construct(protected Firestore $firestore)
    {
        $this->collection = $firestore->database()->collection('usage_logs');
    }

    public function all(): array
    {
        $result = [];
        foreach ($this->collection->documents() as $doc) {
            if ($doc->exists()) {
                $result[] = UsageLogModel::fromFirestore($doc->id(), $doc->data());
            }
        }
        return $result;
    }

    /**
     * jenis_aktivitas = "error" saja, sesuai UC-012.
     */
    public function errorsOnly(): array
    {
        $result = [];
        $query = $this->collection->where('jenis_aktivitas', '=', 'error');
        foreach ($query->documents() as $doc) {
            if ($doc->exists()) {
                $result[] = UsageLogModel::fromFirestore($doc->id(), $doc->data());
            }
        }
        return $result;
    }

    public function delete(string $id): void
    {
        $this->collection->document($id)->delete();
    }

    public function purgeAll(): void
    {
        foreach ($this->collection->documents() as $doc) {
            $doc->reference()->delete();
        }
    }
}
