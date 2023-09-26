import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../entities/partner_store.dart';
import '../../repositories/partner_store_repository.dart';
import '../../usecases/partner_store_use_case.dart';
import '../list/partner_store_list.dart';
import '../logout.dart';
import '../register/store_register.dart';

/// Provider for admin home page
class AdminHomeState with ChangeNotifier {
  /// Constructor
  AdminHomeState() {
    getLists();
  }

  /// For [PartnerStore] operations
  final PartnerStoreUseCase partnerStoreUseCase = PartnerStoreUseCase(
    const PartnerStoreRepository(),
  );

  /// List of all [PartnerStore]s
  late Future<List<PartnerStore>> partnerStores;

  /// Which page is selected in the navigation bar
  int navigationBarSelectedIndex = 0;

  /// Method to change NavBar selected item
  Future<void> changePage(int index) async {
    navigationBarSelectedIndex = index;
    notifyListeners();
  }

  /// Called when a PartnerStore gets registered
  Future<void> onRegister(PartnerStore partnerStore) async {
    // Add to list
    await getLists();

    // Update widget
    notifyListeners();
  }

  /// Method to update variables
  Future<void> getLists() async {
    partnerStores = partnerStoreUseCase.select();
  }
}

/// Admin home page widget
class AdminHomePage extends StatelessWidget {
  /// Constructor
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AdminHomeState>(
      create: (context) {
        return AdminHomeState();
      },
      child: Consumer<AdminHomeState>(
        builder: (_, state, __) {
          // Get page based on current selected index
          late Widget page;
          switch (state.navigationBarSelectedIndex) {
            case 0:
              // Listing of partner stores
              page = PartnerStoreListPage(items: state.partnerStores);
              break;
            case 1:
              // Register a new partner store
              page = RegisterStoreForm(onRegister: state.onRegister);
              break;
            case 2:
              // Statistics
              page = const Center(
                child: Text('Statistics'),
              );
              break;
            case 3:
              // Sales
              page = const Center(
                child: Text('Sales'),
              );
              break;
            case 4:
              // Settings
              page = const Center(child: Text('Settings'));
            case 5:
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
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('Drive Deal'),
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
                    Icons.add_business_outlined,
                    color: Color.fromRGBO(13, 71, 161, 1),
                  ),
                  label: 'Register',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.leaderboard_outlined,
                    color: Color.fromRGBO(13, 71, 161, 1),
                  ),
                  label: 'Statistics',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.account_balance_wallet_outlined,
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
