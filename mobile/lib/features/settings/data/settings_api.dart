import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../auth/data/auth_models.dart';
import 'settings_models.dart';

final settingsApiProvider =
    Provider<SettingsApi>((ref) => SettingsApi(ref.watch(dioProvider)));

class SettingsApi {
  SettingsApi(this._dio);

  final Dio _dio;

  Future<Organization> getOrganization() => guardApi(() async {
        final res = await _dio
            .get<Map<String, dynamic>>('/api/settings/organization');
        return Organization.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  Future<Organization> updateOrganization({
    required String name,
    String? phone,
    String? address,
  }) =>
      guardApi(() async {
        final res = await _dio.put<Map<String, dynamic>>(
            '/api/settings/organization',
            data: {'name': name, 'phone': phone, 'address': address});
        return Organization.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  /// Update profil; sertakan [currentPassword]+[newPassword] untuk ganti password.
  Future<User> updateProfile({
    required String fullName,
    String? phone,
    String? currentPassword,
    String? newPassword,
    String? newPasswordConfirmation,
  }) =>
      guardApi(() async {
        final res = await _dio.put<Map<String, dynamic>>(
            '/api/settings/profile',
            data: {
              'full_name': fullName,
              'phone': phone,
              'current_password': ?currentPassword,
              'new_password': ?newPassword,
              'new_password_confirmation': ?newPasswordConfirmation,
            });
        return User.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  Future<String> uploadLogo(String filePath) => guardApi(() async {
        final form = FormData.fromMap(
            {'logo': await MultipartFile.fromFile(filePath)});
        final res = await _dio.post<Map<String, dynamic>>(
            '/api/settings/organization/logo',
            data: form);
        final data = res.data!['data'] as Map<String, dynamic>? ?? const {};
        return data['logo_url'] as String? ?? '';
      });

  Future<void> deleteLogo() =>
      guardApi(() => _dio.delete('/api/settings/organization/logo'));

  Future<List<PaymentMethodItem>> getPaymentMethods() => guardApi(() async {
        final res = await _dio
            .get<Map<String, dynamic>>('/api/settings/payment-methods');
        return (res.data!['data'] as List? ?? const [])
            .map((e) => PaymentMethodItem.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  Future<void> updatePaymentMethods(List<PaymentMethodItem> methods) =>
      guardApi(() => _dio.put('/api/settings/payment-methods', data: {
            'payment_methods': [for (final m in methods) m.toJson()],
          }));

  /// Field payload memakai nama backend: email_reminder, wa_reminder, reminder_time.
  Future<void> updateNotificationPrefs(NotificationPrefs prefs) =>
      guardApi(() =>
          _dio.put('/api/settings/notifications', data: prefs.toJson()));

  // Team members (owner/admin)
  Future<List<TeamMember>> listTeamMembers() => guardApi(() async {
        final res = await _dio.get<Map<String, dynamic>>('/api/team-members');
        return (res.data!['data'] as List? ?? const [])
            .map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  Future<void> inviteTeamMember(
          {required String email, required String role}) =>
      guardApi(() => _dio
          .post('/api/team-members', data: {'email': email, 'role': role}));

  Future<void> updateMemberRole(String id, String role) =>
      guardApi(() => _dio.put('/api/team-members/$id', data: {'role': role}));

  Future<void> removeMember(String id) =>
      guardApi(() => _dio.delete('/api/team-members/$id'));
}

final organizationProvider = FutureProvider<Organization>(
    (ref) => ref.watch(settingsApiProvider).getOrganization());

final paymentMethodsProvider = FutureProvider<List<PaymentMethodItem>>(
    (ref) => ref.watch(settingsApiProvider).getPaymentMethods());

final teamMembersProvider = FutureProvider<List<TeamMember>>(
    (ref) => ref.watch(settingsApiProvider).listTeamMembers());
