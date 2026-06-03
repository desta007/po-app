import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from '@/contexts/auth-context';
import { AppShell } from '@/components/layout/app-shell';
import { LoadingSpinner } from '@/components/ui/loading-spinner';

// Auth pages
import LoginPage from '@/pages/auth/LoginPage';
import RegisterPage from '@/pages/auth/RegisterPage';
import ForgotPasswordPage from '@/pages/auth/ForgotPasswordPage';

// App pages
import DashboardPage from '@/pages/DashboardPage';
import CalendarPage from '@/pages/CalendarPage';
import PurchaseOrderListPage from '@/pages/po/PurchaseOrderListPage';
import PurchaseOrderCreatePage from '@/pages/po/PurchaseOrderCreatePage';
import PurchaseOrderDetailPage from '@/pages/po/PurchaseOrderDetailPage';
import CustomerListPage from '@/pages/customers/CustomerListPage';
import CustomerDetailPage from '@/pages/customers/CustomerDetailPage';
import ProductListPage from '@/pages/products/ProductListPage';
import ReportPage from '@/pages/reports/ReportPage';
import SettingsPage from '@/pages/settings/SettingsPage';

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { isAuthenticated, isLoading } = useAuth();
  if (isLoading) return <div className="flex items-center justify-center min-h-screen"><LoadingSpinner size="lg" /></div>;
  if (!isAuthenticated) return <Navigate to="/login" replace />;
  return <>{children}</>;
}

function GuestRoute({ children }: { children: React.ReactNode }) {
  const { isAuthenticated, isLoading } = useAuth();
  if (isLoading) return <div className="flex items-center justify-center min-h-screen"><LoadingSpinner size="lg" /></div>;
  if (isAuthenticated) return <Navigate to="/dashboard" replace />;
  return <>{children}</>;
}

export default function App() {
  return (
    <Routes>
      {/* Guest routes */}
      <Route path="/login" element={<GuestRoute><LoginPage /></GuestRoute>} />
      <Route path="/register" element={<GuestRoute><RegisterPage /></GuestRoute>} />
      <Route path="/lupa-password" element={<GuestRoute><ForgotPasswordPage /></GuestRoute>} />

      {/* Protected routes */}
      <Route path="/" element={<ProtectedRoute><AppShell /></ProtectedRoute>}>
        <Route index element={<Navigate to="/dashboard" replace />} />
        <Route path="dashboard" element={<DashboardPage />} />
        <Route path="kalender" element={<CalendarPage />} />
        <Route path="pesanan" element={<PurchaseOrderListPage />} />
        <Route path="pesanan/baru" element={<PurchaseOrderCreatePage />} />
        <Route path="pesanan/:id" element={<PurchaseOrderDetailPage />} />
        <Route path="pelanggan" element={<CustomerListPage />} />
        <Route path="pelanggan/:id" element={<CustomerDetailPage />} />
        <Route path="produk" element={<ProductListPage />} />
        <Route path="laporan" element={<ReportPage />} />
        <Route path="pengaturan/*" element={<SettingsPage />} />
      </Route>

      <Route path="*" element={<Navigate to="/dashboard" replace />} />
    </Routes>
  );
}
