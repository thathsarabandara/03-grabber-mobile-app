import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_repository.dart';
import '../../profile/services/profile_service.dart';
import '../../../core/services/biometric_service.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());
final profileServiceProvider = Provider((ref) => ProfileService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider), ref.read(profileServiceProvider));
});

class AuthState {
  final bool isLoading;
  final String? error;
  final String? token;
  final Map<String, dynamic>? user;

  AuthState({this.isLoading = false, this.error, this.token, this.user});

  AuthState copyWith({bool? isLoading, String? error, String? token, Map<String, dynamic>? user}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final ProfileService _profileService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthNotifier(this._repository, this._profileService) : super(AuthState()) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      state = state.copyWith(token: token);
      await fetchUser();
    }
  }

  Future<void> fetchUser() async {
    try {
      final user = await _profileService.getMe();
      state = state.copyWith(user: user);
    } catch (e) {
      // Token might be invalid or expired
      if (e.toString().contains('401') || e.toString().contains('403')) {
        await logout();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _repository.login(email: email, password: password);
      await _storage.write(key: 'auth_token', value: token);
      await _storage.write(key: 'saved_email', value: email);
      await _storage.write(key: 'saved_password', value: password);
      await _storage.write(key: 'has_logged_in_before', value: 'true');
      state = state.copyWith(token: token);
      await fetchUser();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.verifyOtp(email: email, otp: otp);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> resendOtp(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.resendOtp(email: email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.forgotPassword(email: email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.resetPassword(token: token, newPassword: newPassword);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> uploadProfileImage(String filePath) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _profileService.uploadProfileImage(filePath);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> revokeAllSessions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _profileService.revokeAllSessions();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getSessions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sessions = await _profileService.getSessions();
      state = state.copyWith(isLoading: false);
      return sessions;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return [];
    }
  }

  Future<bool> revokeSession(String sessionId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _profileService.revokeSession(sessionId);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateProfile({required String firstName, required String lastName, String? phone}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _profileService.updateProfile(firstName: firstName, lastName: lastName, phone: phone);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _profileService.changePassword(oldPassword: oldPassword, newPassword: newPassword);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> biometricLogin() async {
    try {
      final isEnabled = await _storage.read(key: 'biometrics_enabled') == 'true';
      if (!isEnabled) return false;

      final isSupported = await BiometricService.isBiometricSupported();
      final hasEnrolled = await BiometricService.hasEnrolledBiometrics();
      if (!isSupported || !hasEnrolled) return false;

      final authenticated = await BiometricService.authenticate(
        localizedReason: 'Authenticate to access Grabber',
      );

      if (!authenticated) return false;

      final email = await _storage.read(key: 'saved_email');
      final password = await _storage.read(key: 'saved_password');

      if (email != null && password != null) {
        return await login(email, password);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isBiometricsEnabled() async {
    return await _storage.read(key: 'biometrics_enabled') == 'true';
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    await _storage.write(key: 'biometrics_enabled', value: enabled ? 'true' : 'false');
  }

  Future<bool> hasSavedCredentials() async {
    final email = await _storage.read(key: 'saved_email');
    final password = await _storage.read(key: 'saved_password');
    return email != null && password != null;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    state = AuthState();
  }
}
