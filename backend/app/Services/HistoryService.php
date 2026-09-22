<?php

namespace App\Services;

use App\Models\HistoryModel;
use Kreait\Firebase\Contract\Firestore;

/**
 * Admin read-only ke history (tidak ada insert/update/delete dari sini,
 * sesuai instruksi awal). Dipakai UC-007 statistik dan monitoring.
 */
class HistoryService
{
    protected $collection;

    public function __construct(protected Firestore $firestore)
    {
        $this->collection = $firestore->database()->collection('history');
    }

    public function all(): array
    {
        $result = [];
        foreach ($this->collection->documents() as $doc) {
            if ($doc->exists()) {
                $result[] = HistoryModel::fromFirestore($doc->id(), $doc->data());
            }
        }
        return $result;
    }

    public function forUser(string $userId): array
    {
        $result = [];
        $query = $this->collection->where('id_user', '=', $userId);
        foreach ($query->documents() as $doc) {
            if ($doc->exists()) {
                $result[] = HistoryModel::fromFirestore($doc->id(), $doc->data());
            }
        }
        return $result;
    }

    /**
     * Agregasi sederhana utk UC-007: total scan per type.
     */
    public function statsByType(): array
    {
        $stats = ['zoom' => 0, 'tts' => 0];
        foreach ($this->all() as $entry) {
            if (isset($stats[$entry->type])) {
                $stats[$entry->type]++;
            }
        }
        return $stats;
    }
}
