import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/contexts/auth-context';
import { ChangePasswordForm } from '@/components/settings/change-password-form';
import { ROUTES } from '@/lib/constants';

/**
 * Halaman wajib ganti password — muncul setelah super admin mereset password
 * user ke password sementara (`must_change_password`). Semua halaman lain
 * dialihkan ke sini oleh ProtectedRoute sampai password diganti.
 */
export default function ChangePasswordPage() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = async () => {
    await logout();
    navigate(ROUTES.LOGIN, { replace: true });
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-dark via-primary to-primary-light p-4">
      <div className="w-full max-w-md bg-white rounded-2xl shadow-2xl p-8">
        <div className="text-center mb-6">
          <h1 className="text-2xl font-bold text-primary-dark">Buat Password Baru</h1>
          <p className="text-neutral-medium mt-2 text-sm">
            Password akun <span className="font-semibold">{user?.email}</span> telah direset oleh admin.
            Demi keamanan, ganti password sementara Anda sebelum melanjutkan.
          </p>
        </div>

        <ChangePasswordForm
          currentPasswordLabel="Password Sementara"
          onSuccess={() => navigate(ROUTES.DASHBOARD, { replace: true })}
        />

        <button
          type="button"
          onClick={handleLogout}
          className="mt-4 block w-full text-center text-sm text-primary hover:underline"
        >
          Keluar
        </button>
      </div>
    </div>
  );
}
