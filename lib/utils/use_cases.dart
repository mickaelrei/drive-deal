import '../entities/partner_store.dart';
import '../entities/sale.dart';
import '../entities/user.dart';
import '../entities/vehicle.dart';
import '../repositories/partner_store_repository.dart';
import '../repositories/sale_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/vehicle_repository.dart';
import '../usecases/partner_store_use_case.dart';
import '../usecases/sale_use_case.dart';
import '../usecases/user_use_case.dart';
import '../usecases/vehicle_use_case.dart';

/// Global use case for [User] objects
late final UserUseCase userUseCase;

/// Global use case for [PartnerStore] objects
late final PartnerStoreUseCase partnerStoreUseCase;

/// Global use case for [Vehicle] objects
late final VehicleUseCase vehicleUseCase;

/// Global use case for [Sale] objects
late final SaleUseCase saleUseCase;

var _loaded = false;

/// Method to initialize all global use cases
Future<void> initializeUseCases() async {
  if (_loaded) return;

  userUseCase = UserUseCase(const UserRepository());

  partnerStoreUseCase = PartnerStoreUseCase(const PartnerStoreRepository());

  vehicleUseCase = const VehicleUseCase(VehicleRepository());

  saleUseCase = const SaleUseCase(SaleRepository());

  // Set loaded
  _loaded = true;
}
