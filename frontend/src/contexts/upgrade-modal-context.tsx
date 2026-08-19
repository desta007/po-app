import { createContext, useContext, useState, useEffect, useCallback, type ReactNode } from 'react';
import { useAuth } from './auth-context';

const SESSION_KEY = 'premium_modal_shown';

interface UpgradeModalContextType {
  open: boolean;
  openModal: () => void;
  closeModal: () => void;
}

const UpgradeModalContext = createContext<UpgradeModalContextType | undefined>(undefined);

export function UpgradeModalProvider({ children }: { children: ReactNode }) {
  const [open, setOpen] = useState(false);
  const { organizationPlan, isSuperAdmin } = useAuth();

  const openModal = useCallback(() => setOpen(true), []);
  const closeModal = useCallback(() => {
    setOpen(false);
    sessionStorage.setItem(SESSION_KEY, 'true');
  }, []);

  // Auto-popup sekali per sesi untuk member free.
  // Pemicu manual (badge header / menu sidebar) tetap bekerja walau flag ini sudah diset.
  useEffect(() => {
    if (organizationPlan === 'premium' || isSuperAdmin) return;

    const alreadyShown = sessionStorage.getItem(SESSION_KEY);
    if (!alreadyShown) {
      const timer = setTimeout(() => setOpen(true), 1500);
      return () => clearTimeout(timer);
    }
  }, [organizationPlan, isSuperAdmin]);

  return (
    <UpgradeModalContext.Provider value={{ open, openModal, closeModal }}>
      {children}
    </UpgradeModalContext.Provider>
  );
}

export function useUpgradeModal() {
  const context = useContext(UpgradeModalContext);
  if (context === undefined) {
    throw new Error('useUpgradeModal harus digunakan di dalam UpgradeModalProvider');
  }
  return context;
}
