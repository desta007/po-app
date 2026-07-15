<?php

namespace App\Http\Concerns;

trait VerifiesCustomerPhone
{
    /**
     * Compare two Indonesian phone numbers ignoring formatting and the
     * interchangeable leading "0" / "62" country prefix.
     */
    protected function phonesMatch(?string $a, ?string $b): bool
    {
        $normalize = static function (?string $phone): string {
            $digits = preg_replace('/\D+/', '', (string) $phone);
            if (str_starts_with($digits, '62')) {
                $digits = '0' . substr($digits, 2);
            }
            return ltrim($digits, '0');
        };

        $na = $normalize($a);
        $nb = $normalize($b);

        return $na !== '' && $na === $nb;
    }
}
