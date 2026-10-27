import '../../../core/errors/app_exception.dart';
import '../../../shared/models/auth_user.dart';
import '../domain/auth_repository.dart';

/// Replace this implementation with a remote repository when a backend exists.
/// It intentionally accepts valid-looking credentials and never stores a password.
final class MockAuthRepository implements AuthRepository {
  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (email.trim().isEmpty || password.isEmpty) {
      throw const AuthException('Please provide your email and password.');
    }
    return AuthUser(
      id: 'demo-user',
      email: email.trim(),
      displayName: 'Alex Morgan',
    );
  }

  @override
  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return AuthUser(
      id: 'demo-user',
      email: email.trim(),
      displayName: name.trim(),
    );
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
}
