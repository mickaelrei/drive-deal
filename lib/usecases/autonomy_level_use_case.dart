import '../entities/autonomy_level.dart';
import '../repositories/autonomy_level_repository.dart';
import '../utils/safety_percent.dart';

/// Class to be used for [AutonomyLevel] operations
class AutonomyLevelUseCase {
  /// Constructor
  const AutonomyLevelUseCase(this._autonomyLevelRepository);

  final AutonomyLevelRepository _autonomyLevelRepository;

  /// Method to select from db
  Future<List<AutonomyLevel>> select() async {
    return _autonomyLevelRepository.select();
  }

  /// Method to insert a [AutonomyLevel] into database
  Future<void> insert(AutonomyLevel autonomyLevel) async {
    // Get total percent
    final totalPercent = safetyPercent +
        autonomyLevel.storePercent +
        autonomyLevel.networkPercent;

    // Check if total percent is roughly equal to 100
    final diff = 100 - totalPercent;
    if (diff.abs() > .001) {
      throw ArgumentError.value(
        autonomyLevel,
        'autonomyLevel',
        'safetyPercent + storePercent + networkPercent != 100%.',
      );
    }

    // Insert and set id
    final id = await _autonomyLevelRepository.insert(autonomyLevel);
    autonomyLevel.id = id;
  }

  /// Method to select by given id
  Future<AutonomyLevel?> selectById(int id) async {
    return _autonomyLevelRepository.selectById(id);
  }
}
