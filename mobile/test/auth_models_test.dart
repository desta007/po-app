import 'package:flutter_test/flutter_test.dart';
import 'package:po_scheduler_mobile/features/auth/data/auth_models.dart';

void main() {
  group('AuthSession.fromJson', () {
    test('parse payload login lengkap (snake_case)', () {
      final session = AuthSession.fromJson({
        'user': {
          'id': 'u-1',
          'email': 'owner@tokokue.id',
          'full_name': 'Budi Santoso',
          'phone': '0812345678',
          'avatar_url': null,
          'current_org_id': 'org-1',
          'is_super_admin': false,
          'role': 'owner',
          'last_login_at': '2026-07-14T08:00:00Z',
          'created_at': '2026-01-01T00:00:00Z',
        },
        'token': 'sanctum-token-123',
        'role': 'owner',
        'is_super_admin': false,
        'organization_plan': 'premium',
        'subscription': {
          'status': 'active',
          'status_label': 'Aktif',
          'starts_at': '2026-01-01',
          'expires_at': '2027-01-01',
        },
      });

      expect(session.user.fullName, 'Budi Santoso');
      expect(session.user.currentOrgId, 'org-1');
      expect(session.token, 'sanctum-token-123');
      expect(session.role, MemberRole.owner);
      expect(session.organizationPlan, 'premium');
      expect(session.subscription?.status, 'active');
    });

    test('parse payload me tanpa token dan field opsional', () {
      final session = AuthSession.fromJson({
        'user': {
          'id': 'u-2',
          'email': 'staf@tokokue.id',
          'full_name': 'Siti',
        },
      });

      expect(session.token, isNull);
      expect(session.role, isNull);
      expect(session.isSuperAdmin, isFalse);
      expect(session.subscription, isNull);
    });

    test('role tak dikenal jatuh ke viewer', () {
      final session = AuthSession.fromJson({
        'user': {'id': 'u-3', 'email': 'x@y.id', 'full_name': 'X'},
        'role': 'role_baru_dari_server',
      });

      expect(session.role, MemberRole.viewer);
    });
  });

  test('RegisterData.toJson memakai snake_case sesuai API', () {
    const data = RegisterData(
      email: 'baru@tokokue.id',
      password: 'rahasia123',
      passwordConfirmation: 'rahasia123',
      fullName: 'Pemilik Baru',
      phone: '0811111111',
      businessName: 'Toko Kue Baru',
    );

    final json = data.toJson();
    expect(json['password_confirmation'], 'rahasia123');
    expect(json['full_name'], 'Pemilik Baru');
    expect(json['business_name'], 'Toko Kue Baru');
  });

  test('MemberRole.canManageOrg hanya owner/admin', () {
    expect(MemberRole.owner.canManageOrg, isTrue);
    expect(MemberRole.admin.canManageOrg, isTrue);
    expect(MemberRole.staff.canManageOrg, isFalse);
    expect(MemberRole.viewer.canManageOrg, isFalse);
  });
}
