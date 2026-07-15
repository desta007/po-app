// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  email: json['email'] as String,
  fullName: json['full_name'] as String,
  phone: json['phone'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  currentOrgId: json['current_org_id'] as String?,
  isSuperAdmin: json['is_super_admin'] as bool? ?? false,
  role: $enumDecodeNullable(
    _$MemberRoleEnumMap,
    json['role'],
    unknownValue: MemberRole.viewer,
  ),
  lastLoginAt: json['last_login_at'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'full_name': instance.fullName,
  'phone': instance.phone,
  'avatar_url': instance.avatarUrl,
  'current_org_id': instance.currentOrgId,
  'is_super_admin': instance.isSuperAdmin,
  'role': _$MemberRoleEnumMap[instance.role],
  'last_login_at': instance.lastLoginAt,
  'created_at': instance.createdAt,
};

const _$MemberRoleEnumMap = {
  MemberRole.owner: 'owner',
  MemberRole.admin: 'admin',
  MemberRole.staff: 'staff',
  MemberRole.viewer: 'viewer',
};

_SubscriptionInfo _$SubscriptionInfoFromJson(Map<String, dynamic> json) =>
    _SubscriptionInfo(
      status: json['status'] as String,
      statusLabel: json['status_label'] as String?,
      startsAt: json['starts_at'] as String?,
      expiresAt: json['expires_at'] as String?,
    );

Map<String, dynamic> _$SubscriptionInfoToJson(_SubscriptionInfo instance) =>
    <String, dynamic>{
      'status': instance.status,
      'status_label': instance.statusLabel,
      'starts_at': instance.startsAt,
      'expires_at': instance.expiresAt,
    };

_AuthSession _$AuthSessionFromJson(Map<String, dynamic> json) => _AuthSession(
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  token: json['token'] as String?,
  role: $enumDecodeNullable(
    _$MemberRoleEnumMap,
    json['role'],
    unknownValue: MemberRole.viewer,
  ),
  isSuperAdmin: json['is_super_admin'] as bool? ?? false,
  organizationPlan: json['organization_plan'] as String?,
  subscription: json['subscription'] == null
      ? null
      : SubscriptionInfo.fromJson(json['subscription'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AuthSessionToJson(_AuthSession instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
      'token': instance.token,
      'role': _$MemberRoleEnumMap[instance.role],
      'is_super_admin': instance.isSuperAdmin,
      'organization_plan': instance.organizationPlan,
      'subscription': instance.subscription?.toJson(),
    };

_RegisterData _$RegisterDataFromJson(Map<String, dynamic> json) =>
    _RegisterData(
      email: json['email'] as String,
      password: json['password'] as String,
      passwordConfirmation: json['password_confirmation'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      businessName: json['business_name'] as String,
    );

Map<String, dynamic> _$RegisterDataToJson(_RegisterData instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'password_confirmation': instance.passwordConfirmation,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'business_name': instance.businessName,
    };
