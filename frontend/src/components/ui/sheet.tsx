import { useEffect, type ReactNode } from 'react';
import { createPortal } from 'react-dom';
import { cn } from '@/lib/utils';
import { X } from 'lucide-react';

interface SheetProps {
  open: boolean;
  onClose: () => void;
  children: ReactNode;
  side?: 'right' | 'bottom';
  className?: string;
  title?: string;
}

function Sheet({ open, onClose, children, side = 'right', className, title }: SheetProps) {
  useEffect(() => {
    if (open) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }
    return () => {
      document.body.style.overflow = '';
    };
  }, [open]);

  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    };
    if (open) {
      document.addEventListener('keydown', handleEscape);
    }
    return () => document.removeEventListener('keydown', handleEscape);
  }, [open, onClose]);

  if (!open) return null;

  return createPortal(
    <div className="fixed inset-0 z-50">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/50 backdrop-blur-sm animate-in fade-in duration-200"
        onClick={onClose}
      />
      {/* Sheet Panel */}
      <div
        className={cn(
          'absolute bg-surface shadow-2xl flex flex-col',
          side === 'right' && [
            'top-0 right-0 h-full w-full max-w-lg',
            'animate-in slide-in-from-right duration-300',
          ],
          side === 'bottom' && [
            'bottom-0 left-0 right-0 max-h-[85vh] rounded-t-2xl',
            'animate-in slide-in-from-bottom duration-300',
          ],
          className
        )}
      >
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-border shrink-0">
          <h2 className="text-lg font-semibold text-neutral">{title}</h2>
          <button
            onClick={onClose}
            className="p-1 rounded-lg text-neutral-medium hover:text-neutral hover:bg-neutral-light transition-colors duration-200"
          >
            <X className="h-5 w-5" />
          </button>
        </div>
        {/* Content */}
        <div className="flex-1 overflow-y-auto">
          {children}
        </div>
      </div>
    </div>,
    document.body
  );
}

export { Sheet };
