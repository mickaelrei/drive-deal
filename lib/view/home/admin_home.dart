import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../entities/partner_store.dart';
import '../../entities/user.dart';
import '../../repositories/partner_store_repository.dart';
import '../../usecases/partner_store_use_case.dart';
import '../list/partner_store_list.dart';
import '../logout.dart';
import '../register/partner_store_register.dart';
import '../unknown_page.dart';
import '../user_settings.dart';

/// Provider for admin home page
class AdminHomeState with ChangeNotifier {
  /// Constructor
  AdminHomeState() {
    unawaited(getLists());
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
  const AdminHomePage({required this.user, super.key});

  /// Reference to [User] object
  final User user;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AdminHomeState>(
      create: (context) {
        return AdminHomeState();
      },
      child: Consumer<AdminHomeState>(
        builder: (_, state, __) {
          // Create nav bar
          final navBar = AdminBottomNavigationBar(
            onSelected: state.changePage,
            selectedIndex: state.navigationBarSelectedIndex,
          );

          // Get page based on current selected index
          late final Widget page;
          switch (state.navigationBarSelectedIndex) {
            case 0:
              // Listing of partner stores
              page = PartnerStoreListPage(
                navBar: navBar,
                items: state.partnerStores,
              );
              break;
            case 1:
              // Register a new partner store
              page = PartnerStoreRegisterForm(
                navBar: navBar,
                onRegister: state.onRegister,
              );
              break;
            case 2:
              // Settings
              page = UserSettingsPage(user: user);
            case 3:
              // Logout
              page = LogoutPage(navBar: navBar);
            default:
              // Error
              page = UnknownPage(navBar: navBar);
              break;
          }

          return page;
        },
      ),
    );
  }
}

/// Nav bar for partner
class AdminBottomNavigationBar extends StatelessWidget {
  /// Constructor
  const AdminBottomNavigationBar({
    this.onSelected,
    this.selectedIndex = 0,
    super.key,
  });

  /// Callback for destination selected
  final void Function(int)? onSelected;

  /// Index of selected destination
  final int selectedIndex;

  /// Icon color
  static const Color destinationColor = Color.fromRGBO(13, 71, 161, 1);

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: onSelected,
      animationDuration: const Duration(milliseconds: 1000),
      backgroundColor: Colors.grey.shade200,
      indicatorColor: Colors.blue.shade300,
      selectedIndex: selectedIndex,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(
            Icons.home_outlined,
            color: destinationColor,
          ),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.add_business_outlined,
            color: destinationColor,
          ),
          label: 'Register',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.settings,
            color: destinationColor,
          ),
          label: 'Settings',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.logout,
            color: destinationColor,
          ),
          label: 'Logout',
        ),
      ],
    );
  }
}
