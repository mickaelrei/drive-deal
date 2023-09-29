import 'dart:developer' as dev;
import 'dart:math';

import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Class to be used for [User] operations
class UserUseCase {
  /// Constructor
  UserUseCase(this._userRepository);

  final UserRepository _userRepository;

  final _random = Random();

  /// Method to select from db
  Future<List<User>> select() async {
    return _userRepository.select();
  }

  /// Method to insert a [User] in the database
  Future<void> insert(User user) async {
    final id = await _userRepository.insert(user);
    user.id = id;
  }

  /// Method to get admin [User] from given name and password
  Future<User?> getAdmin({
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

  /// Method to get [User] from given storeId and password
  Future<User?> getUser({
    required int storeId,
    required String password,
  }) async {
    // Get all users
    final users = await select();
    for (final user in users) {
      if (user.storeId != storeId) continue;

      // Check if password is the same
      if (user.password == password) {
        return user;
      }
    }

    // If reached here then no user had the same password, so invalid
    return null;
  }

  /// Method to generate a random password
  String generatePassword([int length = 15]) {
    // Generate password
    var password = '';
    for (var i = 0; i < 15; i++) {
      final code = _random.nextInt(42) + 40;
      password += String.fromCharCode(code);
    }

    dev.log('Generated password: $password');
    return password;
  }

  /// Method that returns whether a text is considered a CNPJ
  bool isCNPJ(String text) {
    return int.tryParse(text) != null;
  }
}
