/// Level of autonomy for a partner store
enum AutonomyLevel {
  /// Beginner
  beginner,

  /// Intermediate
  intermediate,

  /// Advanced
  advanced,

  /// Special
  special
}

/// PartnerStore entity
class PartnerStore {
  /// Constructor
  PartnerStore({
    required this.id,
    required this.cnpj,
    required this.name,
    required this.autonomyLevel,
  });

  /// ID for database identification
  final int id;

  /// CNPJ, 14 chars
  final String cnpj;

  /// Store name, 120 chars max
  final String name;

  /// Autonomy level
  final AutonomyLevel autonomyLevel;
}
