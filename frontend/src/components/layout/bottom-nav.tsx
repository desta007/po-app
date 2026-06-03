import { NavLink } from 'react-router-dom';
import { LayoutDashboard, Calendar, ClipboardList, Users, MoreHorizontal } from 'lucide-react';
import { cn } from '@/lib/utils';
import { ROUTES } from '@/lib/constants';

const items = [
  { to: ROUTES.DASHBOARD, icon: LayoutDashboard, label: 'Home' },
  { to: ROUTES.CALENDAR, icon: Calendar, label: 'Kalender' },
  { to: ROUTES.PO_LIST, icon: ClipboardList, label: 'PO' },
  { to: ROUTES.CUSTOMERS, icon: Users, label: 'Customer' },
  { to: ROUTES.PRODUCTS, icon: MoreHorizontal, label: 'More' },
];

export function BottomNav() {
  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 lg:hidden z-40">
      <div className="flex items-center justify-around py-2">
        {items.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            className={({ isActive }) => cn(
              'flex flex-col items-center gap-1 px-3 py-1.5 transition-colors',
              isActive ? 'text-primary font-semibold' : 'text-gray-400'
            )}
          >
            <item.icon size={22} />
            <span className="text-[10px] font-semibold">{item.label}</span>
          </NavLink>
        ))}
      </div>
    </nav>
  );
}
