import '../entities/partner_store.dart';
import '../repositories/partner_store_repository.dart';

/// Class to be used for [PartnerStore] operations
class PartnerStoreUseCase {
  /// Constructor
  PartnerStoreUseCase(this._partnerStoreRepository);

  final PartnerStoreRepository _partnerStoreRepository;

  /// Method to select from db
  Future<List<PartnerStore>> select() async {
    return _partnerStoreRepository.select();
  }
}
