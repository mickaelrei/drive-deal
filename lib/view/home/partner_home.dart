import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../entities/partner_store.dart';
import '../../entities/sale.dart';
import '../../entities/vehicle.dart';
import '../list/sale_list.dart';
import '../list/vehicle_list.dart';
import '../logout.dart';

/// Provider for partner home page
class PartnerHomeState with ChangeNotifier {
  /// Constructor
  PartnerHomeState({required this.partnerStore});

  /// What [PartnerStore] is this provider linked to
  final PartnerStore partnerStore;

  /// Which page is selected in the navigation bar
  int navigationBarSelectedIndex = 0;

  /// Method to change NavBar selected item
  Future<void> changePage(int index) async {
    navigationBarSelectedIndex = index;
    notifyListeners();
  }

  /// Callback for when an info about the store was edited
  void onStoreEdit() {
    notifyListeners();
  }

  /// Callback for when a vehicle gets registered
  void onVehicleRegister(Vehicle vehicle) {
    // Add to list of vehicles
    partnerStore.vehicles.add(vehicle);
    notifyListeners();
  }

  /// Callback for when a sale gets registered
  void onSaleRegister(Sale sale) {
    // Add to list of sales
    partnerStore.sales.add(sale);
    notifyListeners();
  }
}

/// Partner Home page widget
class PartnerHomePage extends StatelessWidget {
  /// Constructor
  const PartnerHomePage({required this.partnerStore, super.key});

  /// Reference to [PartnerStore] object
  final PartnerStore partnerStore;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PartnerHomeState>(
      create: (context) {
        return PartnerHomeState(partnerStore: partnerStore);
      },
      child: Consumer<PartnerHomeState>(
        builder: (_, state, __) {
          // Get page and floating action button based on current selected index
          late Widget page;
          FloatingActionButton? actionButton;
          switch (state.navigationBarSelectedIndex) {
            case 0:
              // Home
              page = PartnerInfo(partnerStore: partnerStore);
              actionButton = FloatingActionButton(
                onPressed: () async {
                  // Go in route and check if anything was changed
                  final changed = await Navigator.of(context).pushNamed(
                    '/store_edit',
                    arguments: partnerStore,
                  ) as bool?;

                  if (changed == true) {
                    state.onStoreEdit();
                  }
                },
                child: const Icon(Icons.edit),
              );
              break;
            case 1:
              // Register vehicle
              page = VehicleListPage(partnerStore: partnerStore);
              actionButton = FloatingActionButton(
                onPressed: () async {
                  await Navigator.of(context).pushNamed(
                    '/vehicle_register',
                    arguments: {
                      'partner_store': partnerStore,
                      'on_register': state.onVehicleRegister,
                    },
                  );
                },
                child: const Icon(Icons.add),
              );
              break;
            case 2:
              // Register sale
              page = SaleListPage(partnerStore: partnerStore);
              actionButton = FloatingActionButton(
                onPressed: () async {
                  await Navigator.of(context).pushNamed(
                    '/sale_register',
                    arguments: {
                      'partner_store': partnerStore,
                      'on_register': state.onSaleRegister,
                    },
                  );
                },
                child: const Icon(Icons.add),
              );
              break;
            case 3:
              // Settings
              page = const Center(
                child: Text('Settings'),
              );
              break;
            case 4:
              // Logout
              page = const LogoutPage();
            default:
              // Error
              page = const Center(
                child: Text('Error: Unknown page'),
              );
              break;
          }

          return Scaffold(
            floatingActionButton: actionButton,
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('Partner Home'),
            ),
            body: page,
            bottomNavigationBar: NavigationBar(
              onDestinationSelected: state.changePage,
              animationDuration: const Duration(milliseconds: 1000),
              backgroundColor: Colors.grey.shade200,
              indicatorColor: Colors.blue.shade300,
              selectedIndex: state.navigationBarSelectedIndex,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(
                    Icons.home_outlined,
                    color: Color.fromRGBO(13, 71, 161, 1),
                  ),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.directions_car_filled_rounded,
                    color: Color.fromRGBO(13, 71, 161, 1),
                  ),
                  label: 'Vehicles',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.attach_money,
                    color: Color.fromRGBO(13, 71, 161, 1),
                  ),
                  label: 'Sales',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.settings,
                    color: Color.fromRGBO(13, 71, 161, 1),
                  ),
                  label: 'Settings',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.logout,
                    color: Color.fromRGBO(13, 71, 161, 1),
                  ),
                  label: 'Logout',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Widget for info about [PartnerStore]
class PartnerInfo extends StatelessWidget {
  /// Constructor
  const PartnerInfo({required this.partnerStore, super.key});

  /// Reference to [PartnerStore] object
  final PartnerStore partnerStore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InfoTextHeader('Store name:'),
          InfoText(partnerStore.name),
          const InfoTextHeader('CNPJ:'),
          InfoText(partnerStore.cnpj),
          const InfoTextHeader(
            'Autonomy Level:',
          ),
          InfoText(partnerStore.autonomyLevel.label),
        ],
      ),
    );
  }
}

/// Text that appears before a info text on partner home
class InfoTextHeader extends StatelessWidget {
  /// Constructor
  const InfoTextHeader(this.label, {super.key});

  /// What text to show on the header
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

/// Wrapper for text for partner info
class InfoText extends StatelessWidget {
  /// Constructor
  const InfoText(this.data, {super.key});

  /// Text to show
  final String data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Text(
        data,
        style: const TextStyle(
          fontSize: 25,
        ),
      ),
    );
  }
}
