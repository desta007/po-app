import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '@/contexts/auth-context';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { toast } from 'sonner';
import { ROUTES } from '@/lib/constants';

export default function RegisterPage() {
  const { register } = useAuth();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [form, setForm] = useState({ email: '', password: '', password_confirmation: '', full_name: '', phone: '', business_name: '' });
  const [errors, setErrors] = useState<Record<string, string[]>>({});

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrors({});
    try {
      await register(form);
      toast.success('Registrasi berhasil! Selamat datang.');
      navigate(ROUTES.DASHBOARD);
    } catch (err: any) {
      setErrors(err.response?.data?.errors || {});
      toast.error(err.response?.data?.message || 'Registrasi gagal.');
    } finally {
      setLoading(false);
    }
  };

  const set = (key: string) => (e: React.ChangeEvent<HTMLInputElement>) => setForm({...form, [key]: e.target.value});

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-dark via-primary to-primary-light p-4">
      <div className="w-full max-w-md bg-white rounded-2xl shadow-2xl p-8">
        <div className="text-center mb-6">
          <h1 className="text-3xl font-bold text-primary-dark">📋 PO Scheduler</h1>
          <p className="text-neutral-medium mt-2 text-sm">Buat akun baru</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-3">
          <Input id="reg-name" label="Nama Lengkap" value={form.full_name} onChange={set('full_name')} error={errors.full_name?.[0]} required />
          <Input id="reg-email" label="Email" type="email" value={form.email} onChange={set('email')} error={errors.email?.[0]} required />
          <Input id="reg-phone" label="No. HP" value={form.phone} onChange={set('phone')} />
          <Input id="reg-business" label="Nama Bisnis" value={form.business_name} onChange={set('business_name')} error={errors.business_name?.[0]} required />
          <Input id="reg-password" label="Password" type="password" value={form.password} onChange={set('password')} error={errors.password?.[0]} required />
          <Input id="reg-password-confirm" label="Konfirmasi Password" type="password" value={form.password_confirmation} onChange={set('password_confirmation')} required />
          <Button id="reg-submit" type="submit" className="w-full" loading={loading}>Daftar</Button>
        </form>

        <p className="mt-6 text-center text-sm text-neutral-medium">
          Sudah punya akun? <Link to={ROUTES.LOGIN} className="text-primary font-medium hover:underline">Masuk</Link>
        </p>
      </div>
    </div>
  );
}
