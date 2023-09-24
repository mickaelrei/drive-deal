import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/partner_store.dart';
import 'logout.dart';
import 'register_vehicle.dart';

/// Provider for partner home page
class PartnerHomeState with ChangeNotifier {
  /// Which page is selected in the navigation bar
  int navigationBarSelectedIndex = 0;

  /// Method to change NavBar selected item
  Future<void> changePage(int index) async {
    navigationBarSelectedIndex = index;
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
        return PartnerHomeState();
      },
      child: Consumer<PartnerHomeState>(
        builder: (_, state, __) {
          // Get page based on current selected index
          late Widget page;
          switch (state.navigationBarSelectedIndex) {
            case 0:
              // Home
              page = PartnerInfo(partnerStore: partnerStore);
              break;
            case 1:
              // Register vehicle
              page = const RegisterVehicleForm();
              break;
            case 2:
              // Register sale
              page = const Center(
                child: Text('Register Sale'),
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
            // resizeToAvoidBottomInset: false,
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
                  label: 'Vehicle',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.attach_money,
                    color: Color.fromRGBO(13, 71, 161, 1),
                  ),
                  label: 'Sale',
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
