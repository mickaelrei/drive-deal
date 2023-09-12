/// To be thrown when an insert fails
class DatabaseInsertFailException implements Exception {
  /// Constructor
  DatabaseInsertFailException(this.message);

  /// Exception message
  final String message;
}

/// To be thrown when an entity should have a set ID, but doesn't have
class EntityNoIdException implements Exception {
  /// Constructor
  EntityNoIdException(this.message);

  /// Exception message
  final String message;
}
