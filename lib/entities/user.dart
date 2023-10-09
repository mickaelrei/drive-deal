import '../database/user_table.dart';
import 'partner_store.dart';

/// User entity
class User {
  /// Constructor
  User({
    this.id,
    this.name,
    this.isAdmin = false,
    this.store,
    required this.password,
  });

  /// ID for database identification
  int? id;

  /// Name for admin login
  final String? name;

  /// If this user is an admin, by default false
  final bool isAdmin;

  /// Reference for [PartnerStore] if not an admin
  final PartnerStore? store;

  /// Encrypted password
  final String password;

  /// User settings
  final UserSettings settings = UserSettings();

  /// Map representation of [User] for database operations
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[UserTable.id] = id;
    map[UserTable.isAdmin] = isAdmin ? '1' : '0';
    map[UserTable.password] = password;
    map[UserTable.storeId] = store?.id;
    map[UserTable.name] = name;

    return map;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

/// Class that holds user settings
class UserSettings {
  /// Constructor
  UserSettings({
    this.appTheme = defaultAppTheme,
    this.appLanguage = defaultAppLanguage,
  });

  /// User choice for app theme
  AppTheme appTheme;

  /// User choice for app language
  AppLanguage appLanguage;

  @override
  String toString() {
    return 'App theme: ${appTheme.name}, app language: ${appLanguage.name}';
  }

  /// Default app theme
  static const AppTheme defaultAppTheme = AppTheme.dark;

  /// Default app language
  static const AppLanguage defaultAppLanguage = AppLanguage.english;

  /// Map [String] to [AppTheme]
  static const Map<String, AppTheme> appThemeMap = {
    'dark': AppTheme.dark,
    'light': AppTheme.light
  };

  /// Map [String] to [AppLanguage]
  static const Map<String, AppLanguage> appLanguageMap = {
    'english': AppLanguage.english,
    'portuguese': AppLanguage.portuguese
  };

  /// Method to get app theme preference from string
  static AppTheme getAppTheme(String? themeString) {
    // Find app theme in map
    return appThemeMap[themeString] ?? defaultAppTheme;
  }

  /// Method to get app language preference from string
  static AppLanguage getAppLanguage(String? languageString) {
    // Find app language in map
    return appLanguageMap[languageString] ?? defaultAppLanguage;
  }
}

/// Enum for app languages
enum AppLanguage {
  /// Portuguese language
  portuguese,

  /// English language
  english
}

/// Enum for app themes
enum AppTheme {
  /// Dark theme
  dark,

  /// Light theme
  light
}
