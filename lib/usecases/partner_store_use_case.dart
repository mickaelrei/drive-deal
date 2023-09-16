import '../entities/partner_store.dart';
import '../repositories/partner_store_repository.dart';

/// Class to be used for [PartnerStore] operations
class PartnerStoreUseCase {
  /// Constructor
  const PartnerStoreUseCase(this._partnerStoreRepository);

  final PartnerStoreRepository _partnerStoreRepository;

  /// Method to select from db
  Future<List<PartnerStore>> select() async {
    return _partnerStoreRepository.select();
  }

  /// Method to select by given CNPJ
  Future<PartnerStore?> selectByCNPJ(String cnpj) async {
    return _partnerStoreRepository.selectByCNPJ(cnpj);
  }

  /// Method to insert a [PartnerStore] in the database
  Future<int> insert(PartnerStore partnerStore) async {
    return await _partnerStoreRepository.insert(partnerStore);
  }
}
