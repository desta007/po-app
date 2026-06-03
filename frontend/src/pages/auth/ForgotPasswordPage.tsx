import { useState } from 'react';
import { Link } from 'react-router-dom';
import { authApi } from '@/api/auth';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { toast } from 'sonner';
import { ROUTES } from '@/lib/constants';

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [sent, setSent] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await authApi.forgotPassword(email);
      setSent(true);
      toast.success('Link reset password telah dikirim ke email Anda.');
    } catch {
      toast.error('Gagal mengirim link reset password.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-dark via-primary to-primary-light p-4">
      <div className="w-full max-w-md bg-white rounded-2xl shadow-2xl p-8">
        <div className="text-center mb-6">
          <h1 className="text-2xl font-bold text-primary-dark">Lupa Password</h1>
          <p className="text-neutral-medium mt-2 text-sm">Masukkan email untuk reset password</p>
        </div>

        {sent ? (
          <div className="text-center">
            <div className="text-4xl mb-4">📧</div>
            <p className="text-sm text-neutral-medium">Link reset telah dikirim. Cek email Anda.</p>
            <Link to={ROUTES.LOGIN} className="mt-4 inline-block text-primary hover:underline text-sm">Kembali ke Login</Link>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-4">
            <Input id="forgot-email" label="Email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required autoFocus />
            <Button id="forgot-submit" type="submit" className="w-full" loading={loading}>Kirim Link Reset</Button>
            <Link to={ROUTES.LOGIN} className="block text-center text-sm text-primary hover:underline">Kembali ke Login</Link>
          </form>
        )}
      </div>
    </div>
  );
}
