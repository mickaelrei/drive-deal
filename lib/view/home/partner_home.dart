import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../entities/partner_store.dart';
import '../../entities/sale.dart';
import '../../entities/user.dart';
import '../../entities/vehicle.dart';
import '../../utils/forms.dart';
import '../list/sale_list.dart';
import '../list/vehicle_list.dart';
import '../logout.dart';
import '../unknown_page.dart';
import '../user_settings.dart';

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

  /// Callback for when the theme setting is changed
  void onThemeChanged(AppTheme newTheme) {
    notifyListeners();
  }
}

/// Partner Home page widget
class PartnerHomePage extends StatelessWidget {
  /// Constructor
  const PartnerHomePage({required this.user, super.key});

  /// Reference to [User] object
  final User user;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PartnerHomeState>(
      create: (context) {
        return PartnerHomeState(partnerStore: user.store!);
      },
      child: Consumer<PartnerHomeState>(
        builder: (_, state, __) {
          // Create nav bar
          final navBar = PartnerBottomNavigationBar(
            onSelected: state.changePage,
            selectedIndex: state.navigationBarSelectedIndex,
            theme: user.settings.appTheme,
          );

          // Get page based on current selected index
          late final Widget page;
          switch (state.navigationBarSelectedIndex) {
            case 0:
              // Home
              page = PartnerInfo(
                partnerStore: user.store!,
                navBar: navBar,
                onStoreEdit: state.onStoreEdit,
              );
              break;
            case 1:
              // Register vehicle
              page = VehicleListPage(
                partnerStore: user.store!,
                navBar: navBar,
                onVehicleRegister: state.onVehicleRegister,
                theme: user.settings.appTheme,
              );
              break;
            case 2:
              // Register sale
              page = SaleListPage(
                partnerStore: user.store!,
                navBar: navBar,
                onSaleRegister: state.onSaleRegister,
                theme: user.settings.appTheme,
              );
              break;
            case 3:
              // Settings
              page = UserSettingsPage(
                user: user,
                navBar: navBar,
                onThemeChanged: state.onThemeChanged,
              );
              break;
            case 4:
              // Logout
              page = LogoutPage(navBar: navBar);
            default:
              // Error
              page = UnknownPage(navBar: navBar);
              break;
          }

          return Theme(
            data: user.settings.appTheme == AppTheme.dark
                ? ThemeData.dark()
                : ThemeData.light(),
            child: page,
          );
        },
      ),
    );
  }
}

/// Nav bar for partner
class PartnerBottomNavigationBar extends StatelessWidget {
  /// Constructor
  const PartnerBottomNavigationBar({
    this.onSelected,
    this.selectedIndex = 0,
    this.theme = UserSettings.defaultAppTheme,
    super.key,
  });

  /// Callback for destination selected
  final void Function(int)? onSelected;

  /// Index of selected destination
  final int selectedIndex;

  /// Theme
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    // late Color destinationColor;
    // if (theme == AppTheme.dark) {
    //   destinationColor = const Color.fromARGB(255, 112, 193, 231);
    // } else {
    //   destinationColor = const Color.fromRGBO(13, 71, 161, 1);
    // }

    final destinationColor =
        theme == AppTheme.dark ? Colors.white : Colors.black;

    return NavigationBar(
      onDestinationSelected: onSelected,
      animationDuration: const Duration(milliseconds: 1000),
      selectedIndex: selectedIndex,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      destinations: [
        NavigationDestination(
          icon: Icon(
            Icons.home_outlined,
            color: destinationColor,
          ),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.directions_car_filled_rounded,
            color: destinationColor,
          ),
          label: 'Vehicles',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.attach_money,
            color: destinationColor,
          ),
          label: 'Sales',
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

/// Widget for info about [PartnerStore]
class PartnerInfo extends StatelessWidget {
  /// Constructor
  const PartnerInfo({
    required this.partnerStore,
    this.navBar,
    this.onStoreEdit,
    super.key,
  });

  /// Reference to [PartnerStore] object
  final PartnerStore partnerStore;

  /// Page navigation bar
  final Widget? navBar;

  /// Optional callback for when the [PartnerStore] gets edited
  final void Function()? onStoreEdit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partner Home')),
      bottomNavigationBar: navBar,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Go in route and check if anything was changed
          final changed = await Navigator.of(context).pushNamed(
            '/store_edit',
            arguments: {
              'partner_store': partnerStore,
            },
          ) as bool?;

          if (changed == true && onStoreEdit != null) {
            onStoreEdit!();
          }
        },
        child: const Icon(Icons.edit),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextHeader(label: 'Store name:'),
            InfoText(partnerStore.name),
            const TextHeader(label: 'CNPJ:'),
            InfoText(partnerStore.cnpj),
            const TextHeader(label: 'Autonomy Level:'),
            InfoText(partnerStore.autonomyLevel.label),
          ],
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
