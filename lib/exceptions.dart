import 'entities/autonomy_level.dart';
import 'entities/partner_store.dart';

/// To be thrown when an insert fails
class DatabaseInsertFailException implements Exception {
  /// Constructor
  DatabaseInsertFailException(this.message);

  /// Exception message
  final String? message;

  @override
  String toString() {
    if (message != null) {
      return '$runtimeType: $message';
    } else {
      return '$runtimeType';
    }
  }
}

/// To be thrown when an entity should have a set ID, but doesn't have
class EntityNoIdException implements Exception {
  /// Constructor
  EntityNoIdException(this.message);

  /// Exception message
  final String? message;

  @override
  String toString() {
    if (message != null) {
      return '$runtimeType: $message';
    } else {
      return '$runtimeType';
    }
  }
}

/// To be thrown when the partner home route comes without a [PartnerStore]
class InvalidPartnerStoreException implements Exception {
  /// Constructor
  InvalidPartnerStoreException(this.message);

  /// Exception message
  final String? message;

  @override
  String toString() {
    if (message != null) {
      return '$runtimeType: $message';
    } else {
      return '$runtimeType';
    }
  }
}

/// To be thrown when the partner home route comes without a [AutonomyLevel]
class InvalidAutonomyLevelException implements Exception {
  /// Constructor
  InvalidAutonomyLevelException(this.message);

  /// Exception message
  final String? message;

  @override
  String toString() {
    if (message != null) {
      return '$runtimeType: $message';
    } else {
      return '$runtimeType';
    }
  }
}
