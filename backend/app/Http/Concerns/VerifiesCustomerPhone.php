<?php

namespace App\Http\Concerns;

trait VerifiesCustomerPhone
{
    /**
     * Reduce an Indonesian phone number to its national significant digits,
     * ignoring formatting and the interchangeable leading "0" / "62" prefix.
     * e.g. "+62 812-3456-789" and "08123456789" both become "8123456789".
     */
    protected function normalizePhone(?string $phone): string
    {
        $digits = preg_replace('/\D+/', '', (string) $phone);
        if (str_starts_with($digits, '62')) {
            $digits = '0' . substr($digits, 2);
        }
        return ltrim($digits, '0');
    }

    /**
     * Compare two Indonesian phone numbers ignoring formatting and the
     * interchangeable leading "0" / "62" country prefix.
     */
    protected function phonesMatch(?string $a, ?string $b): bool
    {
        $na = $this->normalizePhone($a);
        $nb = $this->normalizePhone($b);

        return $na !== '' && $na === $nb;
    }
}
