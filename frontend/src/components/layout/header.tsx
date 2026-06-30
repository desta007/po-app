import { Menu, LogOut, User, Crown, Clock } from 'lucide-react';
import { useAuth } from '@/contexts/auth-context';
import { getInitials } from '@/lib/utils';
import { useState, useRef, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { NotificationBell } from '@/components/notifications/notification-bell';

interface HeaderProps {
  onMenuClick: () => void;
}

function SubscriptionBadge() {
  const { organizationPlan, subscription, isSuperAdmin } = useAuth();

  if (isSuperAdmin) return null;

  if (organizationPlan === 'premium' && subscription?.status === 'active') {
    const expiresAt = subscription.expires_at ? new Date(subscription.expires_at) : null;
    const now = new Date();
    const daysLeft = expiresAt ? Math.ceil((expiresAt.getTime() - now.getTime()) / (1000 * 60 * 60 * 24)) : null;

    return (
      <div className="flex items-center gap-1 px-2 py-1 bg-amber-50 border border-amber-200 rounded-lg">
        <Crown size={14} className="text-amber-600 shrink-0" />
        <span className="text-xs font-semibold text-amber-700">Premium</span>
        {daysLeft !== null && (
          <span className="text-xs text-amber-500">
            {daysLeft > 0 ? `${daysLeft} hari lagi` : 'Hari ini berakhir'}
          </span>
        )}
      </div>
    );
  }

  if (subscription?.status === 'pending') {
    return (
      <div className="flex items-center gap-1 px-2 py-1 bg-orange-50 border border-orange-200 rounded-lg">
        <Clock size={14} className="text-orange-500 shrink-0" />
        <span className="text-xs font-semibold text-orange-600 whitespace-nowrap">Menunggu Verifikasi</span>
      </div>
    );
  }

  return (
    <div className="flex items-center gap-1 px-2 py-1 bg-gray-50 border border-gray-200 rounded-lg">
      <span className="text-xs font-semibold text-gray-500">Free</span>
    </div>
  );
}

export function Header({ onMenuClick }: HeaderProps) {
  const { user, logout } = useAuth();
  const [menuOpen, setMenuOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);
  const navigate = useNavigate();

  useEffect(() => {
    const handler = (e: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) setMenuOpen(false);
    };
    document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, []);

  const handleLogout = async () => {
    await logout();
    navigate('/login');
  };

  return (
    <header className="sticky top-0 z-30 h-16 bg-white border-b border-gray-200 flex items-center justify-between px-4 lg:px-8">
      <button onClick={onMenuClick} className="lg:hidden p-2 hover:bg-gray-100 rounded-[10px]">
        <Menu size={22} className="text-gray-700" />
      </button>

      <div className="hidden lg:block text-sm text-gray-500 font-medium">
        PO Scheduler
      </div>

      <div className="flex items-center gap-3">
        <SubscriptionBadge />
        <NotificationBell />

        <div className="relative" ref={menuRef}>
          <button
            onClick={() => setMenuOpen(!menuOpen)}
            className="flex items-center gap-2.5 p-1.5 hover:bg-gray-100 rounded-[10px] transition-colors"
          >
            <div className="w-9 h-9 rounded-full bg-primary text-white flex items-center justify-center text-xs font-bold">
              {getInitials(user?.full_name || 'U')}
            </div>
            <span className="hidden md:block text-sm font-semibold text-gray-900 truncate max-w-[120px]">
              <div className="text-[13px] font-bold text-gray-900">{user?.full_name || 'User Name'}</div>
            </span>
          </button>

          {menuOpen && (
            <div className="absolute right-0 top-full mt-1 w-48 bg-white border border-gray-200 rounded-[10px] shadow-lg py-1 z-50">
              <button onClick={() => { navigate('/pengaturan/profil'); setMenuOpen(false); }}
                className="flex items-center gap-2.5 w-full px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-100">
                <User size={16} /> Profil
              </button>
              <button onClick={handleLogout}
                className="flex items-center gap-2.5 w-full px-4 py-2.5 text-sm text-danger hover:bg-gray-100">
                <LogOut size={16} /> Logout
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
