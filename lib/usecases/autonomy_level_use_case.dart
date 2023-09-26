import '../entities/autonomy_level.dart';
import '../exceptions.dart';
import '../repositories/autonomy_level_repository.dart';

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
  Future<int> insert(AutonomyLevel autonomyLevel) async {
    // Check if store and network percents don't surpass 100%
    final totalPercent =
        autonomyLevel.storePercent + autonomyLevel.networkPercent;
    if (totalPercent > 100) {
      throw InvalidAutonomyLevelException(
        'sum of storePercent and networkPercent surpass 100%.',
      );
    }

    return await _autonomyLevelRepository.insert(autonomyLevel);
  }

  /// Method to select by given id
  Future<AutonomyLevel?> selectById(int id) async {
    return _autonomyLevelRepository.selectById(id);
  }
}
