import { useState } from 'react';
import { authApi } from '@/api/auth';
import { useAuth } from '@/contexts/auth-context';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { toast } from 'sonner';

const EMPTY_FORM = { current_password: '', password: '', password_confirmation: '' };

/**
 * Form ganti password (PUT /api/auth/password). Dipakai di tab Profil Pengaturan
 * dan di halaman wajib-ganti-password setelah reset oleh super admin.
 */
export function ChangePasswordForm({ currentPasswordLabel = 'Password Saat Ini', onSuccess }: {
  currentPasswordLabel?: string;
  onSuccess?: () => void;
}) {
  const { refreshUser } = useAuth();
  const [form, setForm] = useState(EMPTY_FORM);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (form.password !== form.password_confirmation) {
      setErrors({ password_confirmation: 'Konfirmasi password tidak sama.' });
      return;
    }

    setLoading(true);
    setErrors({});
    try {
      const res = await authApi.changePassword(form);
      toast.success(res.data.message);
      setForm(EMPTY_FORM);
      await refreshUser();
      onSuccess?.();
    } catch (err: any) {
      const fieldErrors: Record<string, string[]> | undefined = err.response?.data?.errors;
      if (fieldErrors) {
        setErrors(Object.fromEntries(Object.entries(fieldErrors).map(([k, v]) => [k, v[0] ?? ''])));
      } else {
        toast.error(err.response?.data?.message || 'Gagal mengubah password.');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-3">
      <Input
        id="current-password"
        label={currentPasswordLabel}
        type="password"
        autoComplete="current-password"
        value={form.current_password}
        onChange={(e) => setForm({ ...form, current_password: e.target.value })}
        error={errors.current_password}
        required
      />
      <Input
        id="new-password"
        label="Password Baru"
        type="password"
        autoComplete="new-password"
        value={form.password}
        onChange={(e) => setForm({ ...form, password: e.target.value })}
        error={errors.password}
        helperText="Minimal 8 karakter."
        minLength={8}
        required
      />
      <Input
        id="new-password-confirmation"
        label="Ulangi Password Baru"
        type="password"
        autoComplete="new-password"
        value={form.password_confirmation}
        onChange={(e) => setForm({ ...form, password_confirmation: e.target.value })}
        error={errors.password_confirmation}
        required
      />
      <p className="text-[11px] text-gray-500">Setelah password diubah, sesi login di perangkat lain akan otomatis keluar.</p>
      <Button type="submit" loading={loading}>Ubah Password</Button>
    </form>
  );
}
