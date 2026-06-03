import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '@/contexts/auth-context';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { toast } from 'sonner';
import { ROUTES } from '@/lib/constants';

export default function LoginPage() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [form, setForm] = useState({ email: '', password: '' });
  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrors({});
    try {
      await login(form);
      toast.success('Login berhasil!');
      navigate(ROUTES.DASHBOARD);
    } catch (err: any) {
      const msg = err.response?.data?.message || 'Login gagal.';
      setErrors({ general: msg });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-dark via-primary to-primary-light p-4">
      <div className="w-full max-w-md bg-white rounded-2xl shadow-2xl p-8">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-primary-dark">📋 PO Scheduler</h1>
          <p className="text-neutral-medium mt-2 text-sm">Masuk ke akun Anda</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          {errors.general && <div className="bg-danger/10 text-danger text-sm p-3 rounded-lg">{errors.general}</div>}
          <Input id="login-email" label="Email" type="email" value={form.email} onChange={(e) => setForm({...form, email: e.target.value})} required autoFocus />
          <Input id="login-password" label="Password" type="password" value={form.password} onChange={(e) => setForm({...form, password: e.target.value})} required />
          <Button id="login-submit" type="submit" className="w-full" loading={loading}>Masuk</Button>
        </form>

        <div className="mt-6 text-center text-sm">
          <Link to={ROUTES.FORGOT_PASSWORD} className="text-primary hover:underline">Lupa password?</Link>
          <p className="mt-3 text-neutral-medium">
            Belum punya akun? <Link to={ROUTES.REGISTER} className="text-primary font-medium hover:underline">Daftar</Link>
          </p>
        </div>
      </div>
    </div>
  );
}
