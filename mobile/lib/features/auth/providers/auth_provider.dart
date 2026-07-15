import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_api.dart';
import '../data/auth_models.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.role,
    this.organizationPlan,
    this.subscription,
  });

  final AuthStatus status;
  final User? user;
  final MemberRole? role;
  final String? organizationPlan;
  final SubscriptionInfo? subscription;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get canManageOrg => role?.canManageOrg ?? false;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    MemberRole? role,
    String? organizationPlan,
    SubscriptionInfo? subscription,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        role: role ?? this.role,
        organizationPlan: organizationPlan ?? this.organizationPlan,
        subscription: subscription ?? this.subscription,
      );

  static const unauthenticated = AuthState(status: AuthStatus.unauthenticated);
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  AuthApi get _api => ref.read(authApiProvider);
  TokenStorage get _tokens => ref.read(tokenStorageProvider);

  @override
  AuthState build() {
    // Interceptor dio memanggil ini saat 401 di endpoint terproteksi.
    ref.read(sessionEventsProvider).onUnauthorized = _onUnauthorized;
    Future.microtask(_restoreSession);
    return const AuthState();
  }

  /// App start: kalau ada token tersimpan, validasi ke `/api/auth/me`.
  Future<void> _restoreSession() async {
    final token = await _tokens.read();
    if (token == null || token.isEmpty) {
      state = AuthState.unauthenticated;
      return;
    }
    try {
      final session = await _api.me();
      _applySession(session);
    } catch (_) {
      await _tokens.clear();
      state = AuthState.unauthenticated;
    }
  }

  Future<void> login({required String email, required String password}) async {
    final session = await _api.login(email: email, password: password);
    await _tokens.write(session.token!);
    _applySession(session);
  }

  Future<void> register(RegisterData data) async {
    final session = await _api.register(data);
    await _tokens.write(session.token!);
    _applySession(session);
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {
      // Token sudah tidak valid di server pun tetap logout lokal.
    }
    await _tokens.clear();
    state = AuthState.unauthenticated;
  }

  /// Muat ulang data user dari `/auth/me` tanpa mengubah status login
  /// (dipakai setelah update profil).
  Future<void> refreshUser() async {
    try {
      _applySession(await _api.me());
    } catch (_) {
      // Biarkan state lama; kegagalan refresh bukan alasan logout.
    }
  }

  Future<void> forgotPassword(String email) => _api.forgotPassword(email);

  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) =>
      _api.resetPassword(
        token: token,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

  void _applySession(AuthSession session) {
    state = AuthState(
      status: AuthStatus.authenticated,
      user: session.user,
      role: session.role ?? session.user.role,
      organizationPlan: session.organizationPlan,
      subscription: session.subscription,
    );
  }

  void _onUnauthorized() {
    if (state.status == AuthStatus.authenticated) {
      state = AuthState.unauthenticated;
    }
  }
}
