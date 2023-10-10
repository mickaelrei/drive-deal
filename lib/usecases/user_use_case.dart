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

  /// Method to select from db by given id
  Future<User?> selectById(int id) async {
    return _userRepository.selectById(id);
  }

  /// Method to insert a [User] in the database
  Future<void> insert(User user) async {
    final id = await _userRepository.insert(user);
    user.id = id;
  }

  /// Method to update a [User] in the database
  Future<bool> update(User user) async {
    // Check if any other user has the same name
    final users = await _userRepository.select();
    for (final otherUser in users) {
      // Ignore same user
      if (user.id == otherUser.id) continue;

      // Check if name is the same
      if (user.name == otherUser.name) {
        return false;
      }
    }

    // Await update and return success
    await _userRepository.update(user);
    return true;
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
      // If no partner store (admin) or different id, ignore
      if (user.store == null || user.store!.id != storeId) continue;

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
