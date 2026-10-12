<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Str;

/**
 * Jalan keluar darurat (mis. super admin lupa password) — tidak butuh mail server.
 */
class ResetUserPassword extends Command
{
    protected $signature = 'user:reset-password
        {email : Email akun yang akan direset}
        {--generate : Buat password acak alih-alih mengetik manual}
        {--force-change : Wajibkan user mengganti password saat login berikutnya}';

    protected $description = 'Reset password user (termasuk super admin) dan logout dari semua perangkat.';

    public function handle(): int
    {
        $user = User::where('email', $this->argument('email'))->first();

        if (! $user) {
            $this->error('User dengan email tersebut tidak ditemukan.');

            return self::FAILURE;
        }

        if ($this->option('generate')) {
            $password = Str::password(12, symbols: false);
        } else {
            $password = (string) $this->secret('Password baru (min. 8 karakter)');
            $confirmation = (string) $this->secret('Ulangi password baru');

            if (mb_strlen($password) < 8) {
                $this->error('Password minimal 8 karakter.');

                return self::FAILURE;
            }

            if ($password !== $confirmation) {
                $this->error('Konfirmasi password tidak sama.');

                return self::FAILURE;
            }
        }

        $user->forceFill([
            'password' => $password,
            'must_change_password' => (bool) $this->option('force-change'),
        ])->save();

        $user->tokens()->delete();

        $label = $user->is_super_admin ? 'super admin' : 'user';
        $this->info("Password {$label} {$user->email} berhasil direset. Semua sesi login telah diakhiri.");

        if ($this->option('generate')) {
            $this->line("Password baru: <comment>{$password}</comment>");
        }

        if (! $user->is_active) {
            $this->warn('Catatan: akun ini sedang NONAKTIF, user tetap tidak bisa login sampai diaktifkan.');
        }

        return self::SUCCESS;
    }
}
