import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Class to be used for [User] operations
class UserUseCase {
  /// Constructor
  UserUseCase(this._userRepository);

  final UserRepository _userRepository;

  /// Method to select from db
  Future<List<User>> select() async {
    return _userRepository.select();
  }

  /// Method to get [User] from given name and password
  Future<User?> getUser({
    required String name,
    required String password,
  }) async {
    // Get all users
    final users = await select();
    for (final user in users) {
      if (user.name != name) continue;

      // Check if password is the same
      if (user.password == password) {
        return user;
      }
    }

    // If reached here then no user had the same password, so invalid
    return null;
  }
}
