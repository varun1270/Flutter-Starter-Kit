import '../../../shared/models/auth_user.dart';

abstract interface class AuthRepository {
  Future<AuthUser> signIn({required String email, required String password});
  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> requestPasswordReset(String email);
  Future<void> signOut();
}
