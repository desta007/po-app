import 'package:flutter_test/flutter_test.dart';
import 'package:po_scheduler_mobile/features/settings/data/settings_models.dart';
import 'package:po_scheduler_mobile/features/subscription/data/subscription_models.dart';

void main() {
  test('Organization parse + notification_prefs dari settings JSON', () {
    final org = Organization.fromJson({
      'id': 'org-1',
      'name': 'Toko Kue Sari',
      'slug': 'toko-kue-sari',
      'phone': '0812000',
      'address': 'Jl. Melati 1',
      'logo_url': null,
      'plan': 'premium',
      'settings': {
        'notification_prefs': {
          'email_reminder': false,
          'wa_reminder': true,
          'reminder_time': '07:30',
        },
        'payment_methods': [
          {'name': 'Transfer BCA', 'is_active': true},
        ],
      },
    });
    expect(org.slug, 'toko-kue-sari');
    expect(org.notificationPrefs.emailReminder, isFalse);
    expect(org.notificationPrefs.waReminder, isTrue);
    expect(org.notificationPrefs.reminderTime, '07:30');
  });

  test('Organization tanpa settings → prefs default', () {
    final org = Organization.fromJson({'id': 'o', 'name': 'X'});
    expect(org.notificationPrefs.emailReminder, isTrue);
    expect(org.notificationPrefs.reminderTime, '09:00');
  });

  test('NotificationPrefs.toJson memakai nama field backend', () {
    const prefs = NotificationPrefs(
        emailReminder: true, waReminder: false, reminderTime: '08:00');
    expect(prefs.toJson(), {
      'email_reminder': true,
      'wa_reminder': false,
      'reminder_time': '08:00',
    });
  });

  test('TeamMember parse response team-members', () {
    final m = TeamMember.fromJson({
      'id': 'tm-1',
      'user_id': 'u-1',
      'user_name': 'Budi',
      'user_email': 'budi@toko.id',
      'user_phone': null,
      'user_avatar': null,
      'last_login_at': null,
      'role': 'admin',
      'role_label': 'Admin',
      'joined_at': '2026-01-01',
    });
    expect(m.userName, 'Budi');
    expect(m.role, 'admin');
  });

  test('SubscriptionStatus parse raw JSON dengan latest_subscription', () {
    final s = SubscriptionStatus.fromJson({
      'plan': 'free',
      'plan_label': 'Gratis',
      'is_premium': false,
      'latest_subscription': {
        'id': 'sub-1',
        'status': 'pending',
        'status_label': 'Menunggu',
        'requested_at': '2026-07-01',
        'starts_at': null,
        'expires_at': null,
        'reject_reason': null,
      },
    });
    expect(s.isPremium, isFalse);
    expect(s.latestSubscription?.isPending, isTrue);
  });

  test('SubscriptionStatus tanpa latest_subscription', () {
    final s = SubscriptionStatus.fromJson({
      'plan': 'free',
      'plan_label': 'Gratis',
      'is_premium': false,
      'latest_subscription': null,
    });
    expect(s.latestSubscription, isNull);
  });

  test('QuotaUsage: limit null berarti unlimited', () {
    final q = QuotaUsage.fromJson({
      'is_premium': true,
      'po_monthly': {'current': 120, 'limit': null},
      'products': {'current': 4, 'limit': 10},
      'team_members': {'current': 3, 'limit': 3},
    });
    expect(q.poMonthly.isUnlimited, isTrue);
    expect(q.products.ratio, closeTo(0.4, 0.001));
    expect(q.teamMembers.ratio, 1.0);
  });
}
