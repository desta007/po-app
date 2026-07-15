import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_models.freezed.dart';
part 'settings_models.g.dart';

@freezed
abstract class Organization with _$Organization {
  const Organization._();

  const factory Organization({
    required String id,
    required String name,
    String? slug,
    String? phone,
    String? address,
    String? logoUrl,
    @Default({}) Map<String, dynamic> settings,
    String? plan,
  }) = _Organization;

  /// Preferensi notifikasi tersimpan di `settings.notification_prefs`.
  NotificationPrefs get notificationPrefs {
    final raw = settings['notification_prefs'];
    if (raw is Map<String, dynamic>) return NotificationPrefs.fromJson(raw);
    return const NotificationPrefs();
  }

  factory Organization.fromJson(Map<String, dynamic> json) =>
      _$OrganizationFromJson(json);
}

@freezed
abstract class NotificationPrefs with _$NotificationPrefs {
  const factory NotificationPrefs({
    @Default(true) bool emailReminder,
    @Default(false) bool waReminder,
    @Default('09:00') String reminderTime,
  }) = _NotificationPrefs;

  factory NotificationPrefs.fromJson(Map<String, dynamic> json) =>
      _$NotificationPrefsFromJson(json);
}

@freezed
abstract class PaymentMethodItem with _$PaymentMethodItem {
  const factory PaymentMethodItem({
    required String name,
    @Default(true) bool isActive,
  }) = _PaymentMethodItem;

  factory PaymentMethodItem.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodItemFromJson(json);
}

@freezed
abstract class TeamMember with _$TeamMember {
  const factory TeamMember({
    required String id,
    String? userId,
    required String userName,
    required String userEmail,
    String? userPhone,
    String? userAvatar,
    String? lastLoginAt,
    required String role,
    String? roleLabel,
    String? joinedAt,
  }) = _TeamMember;

  factory TeamMember.fromJson(Map<String, dynamic> json) =>
      _$TeamMemberFromJson(json);
}
