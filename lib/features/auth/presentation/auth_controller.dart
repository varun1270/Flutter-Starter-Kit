import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/auth_user.dart';
import '../data/mock_auth_repository.dart';
import '../domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => MockAuthRepository(),
);
final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthState {
  const AuthState({this.user, this.isLoading = false, this.error});

  final AuthUser? user;
  final bool isLoading;
  final String? error;
}

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    return const AuthState();
  }

  Future<bool> signIn({required String email, required String password}) async {
    state = const AuthState(isLoading: true);
    try {
      final user = await _repository.signIn(email: email, password: password);
      state = AuthState(user: user);
      return true;
    } catch (error) {
      state = AuthState(
        error: error.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AuthState(isLoading: true);
    try {
      final user = await _repository.register(
        name: name,
        email: email,
        password: password,
      );
      state = AuthState(user: user);
      return true;
    } catch (error) {
      state = AuthState(
        error: error.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<String?> requestPasswordReset(String email) async {
    state = const AuthState(isLoading: true);
    try {
      await _repository.requestPasswordReset(email);
      state = const AuthState();
      return null;
    } catch (error) {
      final message = error.toString().replaceFirst('Exception: ', '');
      state = AuthState(error: message);
      return message;
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState();
  }
}
