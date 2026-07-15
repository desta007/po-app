import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

/// Role anggota organisasi — nilai sama dengan `MemberRole` di frontend web.
enum MemberRole {
  owner,
  admin,
  staff,
  viewer;

  bool get canManageOrg => this == owner || this == admin;

  String get label => switch (this) {
        owner => 'Pemilik',
        admin => 'Admin',
        staff => 'Staf',
        viewer => 'Viewer',
      };
}

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String fullName,
    String? phone,
    String? avatarUrl,
    String? currentOrgId,
    @Default(false) bool isSuperAdmin,
    @JsonKey(unknownEnumValue: MemberRole.viewer) MemberRole? role,
    String? lastLoginAt,
    String? createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
abstract class SubscriptionInfo with _$SubscriptionInfo {
  const factory SubscriptionInfo({
    required String status,
    String? statusLabel,
    String? startsAt,
    String? expiresAt,
  }) = _SubscriptionInfo;

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionInfoFromJson(json);
}

/// Response `/api/auth/login`, `/api/auth/register`, dan `/api/auth/me`
/// (pada `me`, `token` bernilai null).
@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    required User user,
    String? token,
    @JsonKey(unknownEnumValue: MemberRole.viewer) MemberRole? role,
    @Default(false) bool isSuperAdmin,
    String? organizationPlan,
    SubscriptionInfo? subscription,
  }) = _AuthSession;

  factory AuthSession.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionFromJson(json);
}

/// Payload `/api/auth/register` — field sama dengan `RegisterData` di web.
@freezed
abstract class RegisterData with _$RegisterData {
  const factory RegisterData({
    required String email,
    required String password,
    required String passwordConfirmation,
    required String fullName,
    required String phone,
    required String businessName,
  }) = _RegisterData;

  factory RegisterData.fromJson(Map<String, dynamic> json) =>
      _$RegisterDataFromJson(json);
}
