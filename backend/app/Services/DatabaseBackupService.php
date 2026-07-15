<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use RuntimeException;
use Symfony\Component\Process\Process;
use Throwable;

class DatabaseBackupService
{
    /**
     * Buat dump database ke file .sql dan kembalikan path file-nya.
     *
     * Utama: pg_dump (dump lengkap: schema + data).
     * Fallback: dump data via PHP jika pg_dump tidak tersedia di server.
     */
    public function dump(): string
    {
        @set_time_limit(0);

        $config = config('database.connections.' . config('database.default'));

        $dir = storage_path('app/backups');
        if (!is_dir($dir)) {
            mkdir($dir, 0755, true);
        }

        $filename = sprintf('backup_%s_%s.sql', $config['database'], now()->format('Ymd_His'));
        $path = $dir . DIRECTORY_SEPARATOR . $filename;

        try {
            $this->dumpWithPgDump($config, $path);
        } catch (Throwable $e) {
            Log::warning('pg_dump tidak tersedia/gagal, memakai fallback PHP dump.', [
                'error' => $e->getMessage(),
            ]);
            $this->dumpWithPhp($config, $path);
        }

        if (!is_file($path) || filesize($path) === 0) {
            @unlink($path);
            throw new RuntimeException('Gagal membuat file backup database.');
        }

        return $path;
    }

    private function dumpWithPgDump(array $config, string $path): void
    {
        $binary = $config['pg_dump_path'] ?? 'pg_dump';

        $process = new Process(
            [
                $binary,
                '--host=' . $config['host'],
                '--port=' . ($config['port'] ?? '5432'),
                '--username=' . $config['username'],
                '--dbname=' . $config['database'],
                '--format=plain',
                '--no-owner',
                '--no-privileges',
                '--file=' . $path,
            ],
            null,
            ['PGPASSWORD' => $config['password']],
            null,
            300
        );

        $process->mustRun();
    }

    /**
     * Fallback tanpa pg_dump: dump data (TRUNCATE + INSERT) semua tabel di schema public.
     * Restore: jalankan `php artisan migrate` dulu untuk membuat struktur tabel,
     * lalu eksekusi file ini (butuh role dengan izin SET session_replication_role).
     */
    private function dumpWithPhp(array $config, string $path): void
    {
        $handle = fopen($path, 'w');
        if ($handle === false) {
            throw new RuntimeException('Tidak dapat menulis file backup.');
        }

        try {
            $tables = DB::table('pg_tables')
                ->where('schemaname', 'public')
                ->whereNotIn('tablename', ['migrations'])
                ->orderBy('tablename')
                ->pluck('tablename')
                ->all();

            fwrite($handle, "-- PO Scheduler database backup (data only, PHP fallback)\n");
            fwrite($handle, '-- Database: ' . $config['database'] . "\n");
            fwrite($handle, '-- Generated: ' . now()->toDateTimeString() . "\n");
            fwrite($handle, "-- Restore: jalankan `php artisan migrate` terlebih dahulu, lalu eksekusi file ini.\n\n");
            fwrite($handle, "BEGIN;\n");
            fwrite($handle, "SET session_replication_role = replica;\n\n");

            if ($tables !== []) {
                $quoted = implode(', ', array_map(fn ($t) => '"' . $t . '"', $tables));
                fwrite($handle, "TRUNCATE TABLE {$quoted} RESTART IDENTITY CASCADE;\n\n");
            }

            foreach ($tables as $table) {
                $this->writeTableData($handle, $table);
            }

            $this->writeSequenceResets($handle, $tables);

            fwrite($handle, "SET session_replication_role = DEFAULT;\n");
            fwrite($handle, "COMMIT;\n");
        } finally {
            fclose($handle);
        }
    }

    private function writeTableData($handle, string $table): void
    {
        $columns = DB::table('information_schema.columns')
            ->where('table_schema', 'public')
            ->where('table_name', $table)
            ->orderBy('ordinal_position')
            ->pluck('column_name')
            ->all();

        if ($columns === []) {
            return;
        }

        $columnList = implode(', ', array_map(fn ($c) => '"' . $c . '"', $columns));
        $insertPrefix = "INSERT INTO \"{$table}\" ({$columnList}) VALUES\n";

        fwrite($handle, "-- Data: {$table}\n");

        $batch = [];
        foreach (DB::table($table)->cursor() as $row) {
            $values = [];
            foreach ($columns as $column) {
                $values[] = $this->quoteValue($row->{$column} ?? null);
            }
            $batch[] = '(' . implode(', ', $values) . ')';

            if (count($batch) >= 200) {
                fwrite($handle, $insertPrefix . implode(",\n", $batch) . ";\n");
                $batch = [];
            }
        }

        if ($batch !== []) {
            fwrite($handle, $insertPrefix . implode(",\n", $batch) . ";\n");
        }

        fwrite($handle, "\n");
    }

    private function writeSequenceResets($handle, array $tables): void
    {
        $serialColumns = DB::table('information_schema.columns')
            ->where('table_schema', 'public')
            ->whereIn('table_name', $tables)
            ->where('column_default', 'like', 'nextval%')
            ->get(['table_name', 'column_name']);

        if ($serialColumns->isEmpty()) {
            return;
        }

        fwrite($handle, "-- Reset sequences\n");
        foreach ($serialColumns as $col) {
            fwrite($handle, sprintf(
                "SELECT setval(pg_get_serial_sequence('\"%s\"', '%s'), COALESCE((SELECT MAX(\"%s\") FROM \"%s\"), 0) + 1, false);\n",
                $col->table_name,
                $col->column_name,
                $col->column_name,
                $col->table_name
            ));
        }
        fwrite($handle, "\n");
    }

    private function quoteValue(mixed $value): string
    {
        if ($value === null) {
            return 'NULL';
        }

        if (is_bool($value)) {
            return $value ? 'TRUE' : 'FALSE';
        }

        if (is_int($value) || is_float($value)) {
            return (string) $value;
        }

        return DB::getPdo()->quote((string) $value);
    }
}
