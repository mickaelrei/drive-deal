import '../entities/autonomy_level.dart';
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

  /// Method to select by given id
  Future<AutonomyLevel?> selectById(int id) async {
    return _autonomyLevelRepository.selectById(id);
  }
}
