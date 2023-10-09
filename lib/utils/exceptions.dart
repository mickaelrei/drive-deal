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
