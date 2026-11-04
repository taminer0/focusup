import '../models/user_profile.dart';

abstract class UserRepository {
  Future<UserProfile> getProfile(); // GET /me
  Future<void> logout(); // POST /auth/logout
}

class MockUserRepository implements UserRepository {
  @override
  Future<UserProfile> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const UserProfile(
      id: '1',
      name: 'Mine',
      email: 'minguyen@gmail.com',
      taskCount: 5,
      streak: 5,
    );
  }

  @override
  Future<void> logout() async {
    // TODO: xóa token khi có backend
  }
}