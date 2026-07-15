// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Organization _$OrganizationFromJson(Map<String, dynamic> json) =>
    _Organization(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      logoUrl: json['logo_url'] as String?,
      settings: json['settings'] as Map<String, dynamic>? ?? const {},
      plan: json['plan'] as String?,
    );

Map<String, dynamic> _$OrganizationToJson(_Organization instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'phone': instance.phone,
      'address': instance.address,
      'logo_url': instance.logoUrl,
      'settings': instance.settings,
      'plan': instance.plan,
    };

_NotificationPrefs _$NotificationPrefsFromJson(Map<String, dynamic> json) =>
    _NotificationPrefs(
      emailReminder: json['email_reminder'] as bool? ?? true,
      waReminder: json['wa_reminder'] as bool? ?? false,
      reminderTime: json['reminder_time'] as String? ?? '09:00',
    );

Map<String, dynamic> _$NotificationPrefsToJson(_NotificationPrefs instance) =>
    <String, dynamic>{
      'email_reminder': instance.emailReminder,
      'wa_reminder': instance.waReminder,
      'reminder_time': instance.reminderTime,
    };

_PaymentMethodItem _$PaymentMethodItemFromJson(Map<String, dynamic> json) =>
    _PaymentMethodItem(
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$PaymentMethodItemToJson(_PaymentMethodItem instance) =>
    <String, dynamic>{'name': instance.name, 'is_active': instance.isActive};

_TeamMember _$TeamMemberFromJson(Map<String, dynamic> json) => _TeamMember(
  id: json['id'] as String,
  userId: json['user_id'] as String?,
  userName: json['user_name'] as String,
  userEmail: json['user_email'] as String,
  userPhone: json['user_phone'] as String?,
  userAvatar: json['user_avatar'] as String?,
  lastLoginAt: json['last_login_at'] as String?,
  role: json['role'] as String,
  roleLabel: json['role_label'] as String?,
  joinedAt: json['joined_at'] as String?,
);

Map<String, dynamic> _$TeamMemberToJson(_TeamMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'user_name': instance.userName,
      'user_email': instance.userEmail,
      'user_phone': instance.userPhone,
      'user_avatar': instance.userAvatar,
      'last_login_at': instance.lastLoginAt,
      'role': instance.role,
      'role_label': instance.roleLabel,
      'joined_at': instance.joinedAt,
    };
