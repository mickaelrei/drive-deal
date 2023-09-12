import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/partner_store.dart';

import '../repositories/partner_store_repository.dart';

import '../usecases/partner_store_use_case.dart';

import 'register_store.dart';

/// Provider for admin home page
class AdminHomeState with ChangeNotifier {
  /// Constructor
  AdminHomeState() {
    getLists();
  }

  /// For [PartnerStore] operations
  final PartnerStoreUseCase partnerStoreUseCase = PartnerStoreUseCase(
    PartnerStoreRepository(),
  );

  /// List of all [PartnerStore]s
  final partnerStores = <PartnerStore>[];

  /// Which page is selected in the navigation bar
  int navigationBarSelectedIndex = 0;

  /// Method to change NavBar selected item
  Future<void> changePage(int index) async {
    navigationBarSelectedIndex = index;

    // Update lists
    await getLists();

    // Update widget
    notifyListeners();
  }

  /// Method to update variables
  Future<void> getLists() async {
    final items = await partnerStoreUseCase.select();
    partnerStores
      ..clear()
      ..addAll(items);
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
              page = PartnerStoreListView(items: state.partnerStores);
              break;
            case 1:
              page = const RegisterStorePage();
              break;
            case 2:
              page = const Center(
                child: Text('Statistics'),
              );
              break;
            case 3:
              page = const Center(
                child: Text('Sales'),
              );
              break;
            default:
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
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Listing of [PartnerStore]
class PartnerStoreListView extends StatelessWidget {
  /// Constructor
  const PartnerStoreListView({required this.items, super.key});

  /// List of [PartnerStore]
  final List<PartnerStore> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final partnerStore = items[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text('Name: ${partnerStore.name}'),
            subtitle: Text(
              'CNPJ: ${partnerStore.cnpj}\n'
              'Autonomy Level: ${partnerStore.autonomyLevelId}',
            ),
            isThreeLine: true,
            tileColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      },
    );
  }
}
