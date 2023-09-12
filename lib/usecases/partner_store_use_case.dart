import 'dart:math';

import '../entities/partner_store.dart';
import '../repositories/partner_store_repository.dart';

/// Class to be used for [PartnerStore] operations
class PartnerStoreUseCase {
  /// Constructor
  PartnerStoreUseCase(this._partnerStoreRepository);

  final PartnerStoreRepository _partnerStoreRepository;

  final _random = Random();

  /// Method to select from db
  Future<List<PartnerStore>> select() async {
    return _partnerStoreRepository.select();
  }

  /// Method to select with given CNPJ
  Future<List<PartnerStore>> selectFromCNPJ(String cnpj) async {
    return _partnerStoreRepository.selectFromCNPJ(cnpj);
  }

  /// Method to insert a [PartnerStore] in the database
  Future<void> insert(PartnerStore partnerStore) async {
    await _partnerStoreRepository.insert(partnerStore);
  }

  /// Method to generate a random password
  String generatePassword([int length = 15]) {
    var password = '';
    for (var i = 0; i < 15; i++) {
      final code = _random.nextInt(42) + 40;
      password += String.fromCharCode(code);
    }

    return password;
  }
}
