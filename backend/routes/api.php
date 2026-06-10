<?php

use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\Auth\ForgotPasswordController;
use App\Http\Controllers\Auth\ResetPasswordController;
use App\Http\Controllers\CustomerController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\PurchaseOrderController;
use App\Http\Controllers\CalendarController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\SettingController;
use Illuminate\Support\Facades\Route;

// Authentication
Route::prefix('auth')->group(function () {
    Route::post('/register', [RegisterController::class, 'register']);
    Route::post('/login', [LoginController::class, 'login']);
    Route::post('/forgot-password', [ForgotPasswordController::class, 'sendResetLink']);
    Route::post('/reset-password', [ResetPasswordController::class, 'reset']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout', [LoginController::class, 'logout']);
        Route::get('/me', [LoginController::class, 'me']);
    });
});

// Protected routes
Route::middleware(['auth:sanctum', 'org.access'])->group(function () {
    // Customers
    Route::apiResource('customers', CustomerController::class);

    // Products
    Route::apiResource('products', ProductController::class);

    // Purchase Orders
    Route::apiResource('purchase-orders', PurchaseOrderController::class);
    Route::patch('purchase-orders/{purchase_order}/status', [PurchaseOrderController::class, 'updateStatus']);
    Route::patch('purchase-orders/{purchase_order}/payment', [PurchaseOrderController::class, 'updatePayment']);
    Route::post('purchase-orders/{purchase_order}/cancel', [PurchaseOrderController::class, 'cancel']);
    Route::post('purchase-orders/{purchase_order}/duplicate', [PurchaseOrderController::class, 'duplicate']);
    Route::get('purchase-orders/{purchase_order}/export-pdf', [PurchaseOrderController::class, 'exportPdf']);

    // Calendar
    Route::get('calendar/events', [CalendarController::class, 'events']);
    Route::patch('calendar/events/{purchase_order}/reschedule', [CalendarController::class, 'reschedule']);

    // Dashboard
    Route::get('dashboard/today-summary', [DashboardController::class, 'todaySummary']);
    Route::get('dashboard/revenue-chart', [DashboardController::class, 'revenueChart']);
    Route::get('dashboard/top-customers', [DashboardController::class, 'topCustomers']);
    Route::get('dashboard/top-products', [DashboardController::class, 'topProducts']);
    Route::get('dashboard/pending-payments', [DashboardController::class, 'pendingPayments']);

    // Reports
    Route::get('reports/revenue', [ReportController::class, 'revenue']);
    Route::get('reports/export-excel', [ReportController::class, 'exportExcel']);

    // Notifications
    Route::get('notifications', [NotificationController::class, 'index']);
    Route::patch('notifications/{id}/read', [NotificationController::class, 'markRead']);
    Route::patch('notifications/read-all', [NotificationController::class, 'markAllRead']);

    // Settings
    Route::get('settings/organization', [SettingController::class, 'getOrganization']);
    Route::put('settings/organization', [SettingController::class, 'updateOrganization']);
    Route::put('settings/profile', [SettingController::class, 'updateProfile']);
    Route::put('settings/notifications', [SettingController::class, 'updateNotificationPrefs']);
});
