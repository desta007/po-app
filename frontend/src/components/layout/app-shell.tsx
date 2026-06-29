import { Outlet } from 'react-router-dom';
import { Sidebar } from './sidebar';
import { Header } from './header';
import { BottomNav } from './bottom-nav';
import { PremiumUpgradeModal, WA_NUMBER, WA_MESSAGE } from '@/components/premium-upgrade-modal';
import { MessageCircle } from 'lucide-react';
import { useState } from 'react';

export function AppShell() {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="flex min-h-screen">
      {/* Desktop sidebar */}
      <Sidebar open={sidebarOpen} onClose={() => setSidebarOpen(false)} />

      {/* Main content */}
      <div className="flex-1 flex flex-col min-w-0 lg:ml-60">
        <Header onMenuClick={() => setSidebarOpen(true)} />
        <main className="flex-1 overflow-y-auto bg-gray-50 p-4 lg:px-8 lg:py-6 pb-20 lg:pb-6">
          <Outlet />
        </main>
      </div>

      {/* Mobile bottom nav */}
      <BottomNav />

      {/* Floating Chat Us button */}
      <a
        href={`https://wa.me/${WA_NUMBER}?text=${encodeURIComponent(WA_MESSAGE)}`}
        target="_blank"
        rel="noopener noreferrer"
        className="fixed bottom-20 right-4 lg:bottom-6 lg:right-6 z-50 flex items-center gap-2 px-4 py-2.5 rounded-full bg-[#25D366] text-white text-sm font-semibold shadow-lg shadow-green-500/30 hover:shadow-green-500/50 hover:bg-[#20bd5a] transform hover:scale-105 active:scale-95 transition-all duration-200"
      >
        <MessageCircle size={18} />
        Chat Us
      </a>

      {/* Premium upgrade modal */}
      <PremiumUpgradeModal />
    </div>
  );
}
