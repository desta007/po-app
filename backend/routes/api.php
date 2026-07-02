<?php

use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\Auth\ForgotPasswordController;
use App\Http\Controllers\Auth\ResetPasswordController;
use App\Http\Controllers\CustomerController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\ProductImageController;
use App\Http\Controllers\PurchaseOrderController;
use App\Http\Controllers\CalendarController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\SettingController;
use App\Http\Controllers\OrganizationLogoController;
use App\Http\Controllers\TeamMemberController;
use App\Http\Controllers\SuperAdminController;
use App\Http\Controllers\SubscriptionController;
use App\Http\Controllers\PublicCatalogController;
use Illuminate\Support\Facades\Route;

// Public routes (no auth)
Route::get('catalog/{slug}', [PublicCatalogController::class, 'show']);
Route::post('catalog/{slug}/checkout', [PublicCatalogController::class, 'checkout']);

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

// Authenticated routes (no org required)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('notifications', [NotificationController::class, 'index']);
    Route::get('notifications/unread-count', [NotificationController::class, 'unreadCount']);
    Route::patch('notifications/{id}/read', [NotificationController::class, 'markRead']);
    Route::patch('notifications/read-all', [NotificationController::class, 'markAllRead']);
});

// Protected routes
Route::middleware(['auth:sanctum', 'org.access'])->group(function () {
    // Customers
    Route::apiResource('customers', CustomerController::class);

    // Products
    Route::apiResource('products', ProductController::class);
    Route::post('products/{product}/image', [ProductImageController::class, 'store']);
    Route::delete('products/{product}/image', [ProductImageController::class, 'destroy']);

    // Purchase Orders
    Route::post('purchase-orders/bulk-export-pdf', [PurchaseOrderController::class, 'bulkExportPdf']);
    Route::apiResource('purchase-orders', PurchaseOrderController::class);
    Route::patch('purchase-orders/{purchase_order}/status', [PurchaseOrderController::class, 'updateStatus']);
    Route::patch('purchase-orders/{purchase_order}/payment', [PurchaseOrderController::class, 'updatePayment']);
    Route::post('purchase-orders/{purchase_order}/cancel', [PurchaseOrderController::class, 'cancel']);
    Route::post('purchase-orders/{purchase_order}/duplicate', [PurchaseOrderController::class, 'duplicate']);
    Route::get('purchase-orders/{purchase_order}/export-pdf', [PurchaseOrderController::class, 'exportPdf']);
    Route::get('purchase-orders/{purchase_order}/export-corporate-pdf', [PurchaseOrderController::class, 'exportCorporatePdf']);
    Route::get('purchase-orders/{purchase_order}/export-image', [PurchaseOrderController::class, 'exportImage']);
    Route::get('purchase-orders/{purchase_order}/export-html', [PurchaseOrderController::class, 'exportHtml']);

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
    Route::get('reports/profit', [ReportController::class, 'profitReport']);
    Route::get('reports/export-excel', [ReportController::class, 'exportExcel']);

    // Settings
    Route::get('settings/organization', [SettingController::class, 'getOrganization']);
    Route::put('settings/organization', [SettingController::class, 'updateOrganization']);
    Route::put('settings/profile', [SettingController::class, 'updateProfile']);
    Route::put('settings/notifications', [SettingController::class, 'updateNotificationPrefs']);
    Route::post('settings/organization/logo', [OrganizationLogoController::class, 'store']);
    Route::delete('settings/organization/logo', [OrganizationLogoController::class, 'destroy']);
    Route::get('settings/payment-methods', [SettingController::class, 'getPaymentMethods']);
    Route::put('settings/payment-methods', [SettingController::class, 'updatePaymentMethods']);

    // Team Members (owner/admin only)
    Route::middleware('role:owner,admin')->group(function () {
        Route::apiResource('team-members', TeamMemberController::class)->except(['show']);
    });

    // Subscription
    Route::get('subscription/status', [SubscriptionController::class, 'status']);
    Route::post('subscription/request', [SubscriptionController::class, 'requestUpgrade']);
});

// Super Admin routes
Route::middleware(['auth:sanctum', 'super_admin'])->prefix('admin')->group(function () {
    Route::get('dashboard', [SuperAdminController::class, 'dashboard']);
    Route::get('users', [SuperAdminController::class, 'users']);
    Route::get('users/{id}', [SuperAdminController::class, 'userDetail']);
    Route::get('organizations', [SuperAdminController::class, 'organizations']);

    // Subscription management
    Route::get('subscriptions', [SubscriptionController::class, 'subscriptions']);
    Route::patch('subscriptions/{id}/approve', [SubscriptionController::class, 'approveSubscription']);
    Route::patch('subscriptions/{id}/reject', [SubscriptionController::class, 'rejectSubscription']);
});
