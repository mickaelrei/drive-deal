import '../entities/partner_store.dart';
import '../entities/user.dart';
import '../repositories/partner_store_repository.dart';
import '../repositories/user_repository.dart';
import 'user_use_case.dart';

/// Class to be used for [PartnerStore] operations
class PartnerStoreUseCase {
  /// Constructor
  PartnerStoreUseCase(this._partnerStoreRepository);

  final PartnerStoreRepository _partnerStoreRepository;

  final UserUseCase _userUseCase = UserUseCase(const UserRepository());

  /// Method to select from db
  Future<List<PartnerStore>> select() async {
    return _partnerStoreRepository.select();
  }

  /// Method to select by given id
  Future<PartnerStore?> selectById(int id) async {
    return _partnerStoreRepository.selectById(id);
  }

  /// Method to select by given CNPJ
  Future<PartnerStore?> selectByCNPJ(String cnpj) async {
    return _partnerStoreRepository.selectByCNPJ(cnpj);
  }

  /// Method to insert a [PartnerStore] in the database
  Future<void> insert({
    required PartnerStore partnerStore,
    required String password,
  }) async {
    // Get id of inserted store
    final storeId = await _partnerStoreRepository.insert(partnerStore);
    partnerStore.id = storeId;

    // Create user for this partner store
    final user = User(
      store: partnerStore,
      password: password,
    );
    await _userUseCase.insert(user);
  }

  /// Method to update a [PartnerStore] in the database
  Future<void> update(PartnerStore partnerStore) async {
    await _partnerStoreRepository.update(partnerStore);
  }
}
