import { forwardRef, type InputHTMLAttributes, type ReactNode } from 'react';
import { cn } from '@/lib/utils';

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
  helperText?: string;
  prefixIcon?: ReactNode;
  suffixIcon?: ReactNode;
  fullWidth?: boolean;
}

const Input = forwardRef<HTMLInputElement, InputProps>(
  (
    {
      className,
      label,
      error,
      helperText,
      prefixIcon,
      suffixIcon,
      fullWidth = true,
      id,
      ...props
    },
    ref
  ) => {
    const inputId = id || label?.toLowerCase().replace(/\s+/g, '-');

    return (
      <div className={cn('flex flex-col gap-1.5', fullWidth && 'w-full')}>
        {label && (
          <label
            htmlFor={inputId}
            className="text-xs font-semibold text-gray-700"
          >
            {label}
          </label>
        )}
        <div className="relative">
          {prefixIcon && (
            <div className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">
              {prefixIcon}
            </div>
          )}
          <input
            ref={ref}
            id={inputId}
            className={cn(
              'w-full rounded-[6px] border border-gray-300 bg-white px-3 py-2.5 text-[14px] text-gray-900',
              'placeholder:text-gray-400',
              'transition-all duration-150',
              'focus:outline-none focus:border-primary focus:ring-3 focus:ring-primary-50',
              'disabled:bg-gray-100 disabled:cursor-not-allowed disabled:opacity-60',
              error && 'border-danger focus:ring-danger-light focus:border-danger',
              prefixIcon && 'pl-10',
              suffixIcon && 'pr-10',
              className
            )}
            {...props}
          />
          {suffixIcon && (
            <div className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400">
              {suffixIcon}
            </div>
          )}
        </div>
        {error && (
          <p className="text-[11px] text-danger">{error}</p>
        )}
        {helperText && !error && (
          <p className="text-[11px] text-gray-500">{helperText}</p>
        )}
      </div>
    );
  }
);

Input.displayName = 'Input';

export { Input, type InputProps };
