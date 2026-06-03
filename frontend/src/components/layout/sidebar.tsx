import { NavLink } from 'react-router-dom';
import { LayoutDashboard, Calendar, ClipboardList, Users, Package, BarChart3, Settings, X } from 'lucide-react';
import { cn } from '@/lib/utils';
import { ROUTES } from '@/lib/constants';

const mainNav = [
  { to: ROUTES.DASHBOARD, icon: LayoutDashboard, label: 'Dashboard' },
  { to: ROUTES.CALENDAR, icon: Calendar, label: 'Kalender' },
  { to: ROUTES.PO_LIST, icon: ClipboardList, label: 'Purchase Order' },
];

const masterNav = [
  { to: ROUTES.CUSTOMERS, icon: Users, label: 'Customer' },
  { to: ROUTES.PRODUCTS, icon: Package, label: 'Produk' },
];

const analysisNav = [
  { to: ROUTES.REPORTS, icon: BarChart3, label: 'Laporan' },
];

const settingsNav = [
  { to: ROUTES.SETTINGS, icon: Settings, label: 'Settings' },
];

interface SidebarProps {
  open: boolean;
  onClose: () => void;
}

function NavItem({ to, icon: Icon, label, onClose }: { to: string; icon: any; label: string; onClose: () => void }) {
  return (
    <NavLink
      to={to}
      onClick={onClose}
      className={({ isActive }) => cn(
        'flex items-center gap-3 px-3.5 py-2.5 rounded-[10px] text-[14px] font-medium transition-all duration-150 cursor-pointer',
        isActive
          ? 'bg-primary-50 text-primary font-semibold'
          : 'text-gray-700 hover:bg-gray-100'
      )}
    >
      <Icon size={18} />
      {label}
    </NavLink>
  );
}

export function Sidebar({ open, onClose }: SidebarProps) {
  return (
    <>
      {/* Mobile overlay */}
      {open && <div className="fixed inset-0 bg-black/50 z-40 lg:hidden" onClick={onClose} />}

      <aside className={cn(
        'fixed top-0 left-0 h-full w-60 bg-white border-r border-gray-200 z-50 transition-transform duration-300 flex flex-col',
        'lg:translate-x-0',
        open ? 'translate-x-0' : '-translate-x-full'
      )}>
        {/* Logo */}
        <div className="flex items-center justify-between h-16 px-4 flex-shrink-0">
          <div className="text-xl font-extrabold tracking-tight text-primary" style={{ letterSpacing: '-0.02em' }}>
            PO<span className="text-accent">S</span>
          </div>
          <button onClick={onClose} className="lg:hidden p-1 hover:bg-gray-100 rounded-[10px]">
            <X size={20} className="text-gray-500" />
          </button>
        </div>

        {/* Navigation */}
        <nav className="flex-1 overflow-y-auto px-4 pb-4">
          <div className="space-y-1">
            {mainNav.map((item) => (
              <NavItem key={item.to} {...item} onClose={onClose} />
            ))}
          </div>

          <div className="mt-5">
            <div className="text-[11px] font-bold uppercase text-gray-400 tracking-[0.06em] px-3.5 mb-2">Master</div>
            <div className="space-y-1">
              {masterNav.map((item) => (
                <NavItem key={item.to} {...item} onClose={onClose} />
              ))}
            </div>
          </div>

          <div className="mt-5">
            <div className="text-[11px] font-bold uppercase text-gray-400 tracking-[0.06em] px-3.5 mb-2">Analisis</div>
            <div className="space-y-1">
              {analysisNav.map((item) => (
                <NavItem key={item.to} {...item} onClose={onClose} />
              ))}
            </div>
          </div>

          <div className="mt-5">
            <div className="text-[11px] font-bold uppercase text-gray-400 tracking-[0.06em] px-3.5 mb-2">Pengaturan</div>
            <div className="space-y-1">
              {settingsNav.map((item) => (
                <NavItem key={item.to} {...item} onClose={onClose} />
              ))}
            </div>
          </div>
        </nav>
      </aside>
    </>
  );
}
