import type { ReactNode } from 'react';
import { cn } from '@/lib/utils';
import type { POStatus, PaymentStatus } from '@/types/purchase-order';
import { PO_STATUS_CONFIG, PAYMENT_STATUS_CONFIG } from '@/lib/constants';

type BadgeVariant = 'default' | 'primary' | 'secondary' | 'success' | 'warning' | 'danger' | 'outline';

interface BadgeProps {
  children: ReactNode;
  variant?: BadgeVariant;
  className?: string;
  dot?: boolean;
  style?: React.CSSProperties;
}

const variantClasses: Record<BadgeVariant, string> = {
  default: 'bg-gray-100 text-gray-700',
  primary: 'bg-primary-50 text-primary',
  secondary: 'bg-primary-100 text-primary',
  success: 'bg-accent-light text-accent',
  warning: 'bg-warning-light text-amber-700',
  danger: 'bg-danger-light text-danger',
  outline: 'border border-gray-300 text-gray-700 bg-transparent',
};

function Badge({ children, variant = 'default', className, dot, style }: BadgeProps) {
  return (
    <span
      className={cn(
        'inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[11px] font-semibold',
        variantClasses[variant],
        className
      )}
      style={style}
    >
      {dot && (
        <span
          className="h-1.5 w-1.5 rounded-full bg-current"
        />
      )}
      {children}
    </span>
  );
}

function POStatusBadge({ status }: { status: POStatus }) {
  const config = PO_STATUS_CONFIG[status];
  return (
    <span
      className="inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[11px] font-semibold"
      style={{ backgroundColor: config.bgColor, color: config.color }}
    >
      <span
        className="h-1.5 w-1.5 rounded-full"
        style={{ backgroundColor: config.color }}
      />
      {config.label}
    </span>
  );
}

function PaymentStatusBadge({ status }: { status: PaymentStatus }) {
  const config = PAYMENT_STATUS_CONFIG[status];
  return (
    <span
      className="inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[11px] font-semibold"
      style={{ backgroundColor: config.bgColor, color: config.color }}
    >
      <span
        className="h-1.5 w-1.5 rounded-full"
        style={{ backgroundColor: config.color }}
      />
      {config.label}
    </span>
  );
}

export { Badge, POStatusBadge, PaymentStatusBadge, type BadgeProps, type BadgeVariant };
