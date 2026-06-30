import { useEffect, useRef, type ReactNode } from 'react';
import { createPortal } from 'react-dom';
import { cn } from '@/lib/utils';
import { X } from 'lucide-react';

interface DialogProps {
  open: boolean;
  onClose?: () => void;
  onOpenChange?: (open: boolean) => void;
  children: ReactNode;
  className?: string;
  size?: 'sm' | 'md' | 'lg' | 'xl';
}

interface DialogHeaderProps {
  children: ReactNode;
  onClose?: () => void;
  className?: string;
}

const sizeClasses = {
  sm: 'max-w-sm',
  md: 'max-w-md',
  lg: 'max-w-lg',
  xl: 'max-w-xl',
};

function Dialog({ open, onClose, onOpenChange, children, className, size = 'md' }: DialogProps) {
  const overlayRef = useRef<HTMLDivElement>(null);
  const handleClose = () => {
    onClose?.();
    onOpenChange?.(false);
  };

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
      if (e.key === 'Escape') handleClose();
    };
    if (open) {
      document.addEventListener('keydown', handleEscape);
    }
    return () => document.removeEventListener('keydown', handleEscape);
  }, [open]);

  if (!open) return null;

  return createPortal(
    <div
      ref={overlayRef}
      className={cn(
        'fixed inset-0 z-50 flex items-center justify-center p-4',
        'animate-in fade-in duration-200'
      )}
      onClick={(e) => {
        if (e.target === overlayRef.current) handleClose();
      }}
    >
      {/* Backdrop */}
      <div className="absolute inset-0 bg-gray-900/60 backdrop-blur-sm" />
      {/* Dialog */}
      <div
        className={cn(
          'relative w-full bg-white rounded-[10px] shadow-lg border border-gray-200 max-h-[calc(100vh-2rem)] overflow-y-auto',
          'animate-in zoom-in-95 slide-in-from-bottom-2 duration-300',
          sizeClasses[size],
          className
        )}
      >
        {children}
      </div>
    </div>,
    document.body
  );
}

function DialogHeader({ children, onClose, className }: DialogHeaderProps) {
  return (
    <div className={cn('flex items-center justify-between px-5 py-4 border-b border-gray-200', className)}>
      <div className="text-[16px] font-bold text-gray-900">{children}</div>
      {onClose && (
        <button
          onClick={onClose}
          className="p-1 rounded-lg text-gray-500 hover:text-gray-900 hover:bg-gray-100 transition-colors"
        >
          <X size={18} />
        </button>
      )}
    </div>
  );
}

function DialogTitle({ children, className }: { children: ReactNode; className?: string }) {
  return <span className={cn('text-[16px] font-bold text-gray-900', className)}>{children}</span>;
}

function DialogContent({ children, className }: { children: ReactNode; className?: string }) {
  return (
    <div className={cn('px-5 py-5', className)}>
      {children}
    </div>
  );
}

function DialogBody({ children, className }: { children: ReactNode; className?: string }) {
  return (
    <div className={cn('px-5 py-5', className)}>
      {children}
    </div>
  );
}

function DialogFooter({ children, className }: { children: ReactNode; className?: string }) {
  return (
    <div className={cn('flex items-center justify-end gap-2 px-5 py-4 border-t border-gray-200 bg-gray-50 rounded-b-[10px]', className)}>
      {children}
    </div>
  );
}

export { Dialog, DialogHeader, DialogBody, DialogFooter, DialogContent, DialogTitle };
