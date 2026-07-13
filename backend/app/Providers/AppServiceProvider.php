<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        RateLimiter::for('login', function (Request $request) {
            $key = $request->input('email', '') . '|' . $request->ip();
            return Limit::perMinute(5)->by($key)->response(function () {
                return response()->json([
                    'message' => 'Terlalu banyak percobaan login. Silakan coba lagi dalam 1 menit.',
                ], 429);
            });
        });

        RateLimiter::for('register', function (Request $request) {
            return Limit::perMinute(3)->by($request->ip())->response(function () {
                return response()->json([
                    'message' => 'Terlalu banyak percobaan registrasi. Silakan coba lagi dalam 1 menit.',
                ], 429);
            });
        });

        RateLimiter::for('password-reset', function (Request $request) {
            return Limit::perMinute(3)->by($request->ip())->response(function () {
                return response()->json([
                    'message' => 'Terlalu banyak permintaan reset password. Silakan coba lagi dalam 1 menit.',
                ], 429);
            });
        });

        RateLimiter::for('catalog-checkout', function (Request $request) {
            return Limit::perMinute(5)->by($request->ip())->response(function () {
                return response()->json([
                    'message' => 'Terlalu banyak pesanan dalam waktu singkat. Silakan coba lagi dalam 1 menit.',
                ], 429);
            });
        });
    }
}
