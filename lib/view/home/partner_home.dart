import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../entities/partner_store.dart';
import '../../entities/sale.dart';
import '../../entities/user.dart';
import '../../entities/vehicle.dart';
import '../../utils/forms.dart';
import '../list/sale_list.dart';
import '../list/vehicle_list.dart';
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

  /// Callback for when the language setting is changed
  void onLanguageChanged(AppLanguage newLanguage) {
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
              page = PartnerInfoPage(
                user: user,
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
              );
              break;
            case 2:
              // Register sale
              page = SaleListPage(
                partnerStore: user.store!,
                navBar: navBar,
                onSaleRegister: state.onSaleRegister,
              );
              break;
            case 3:
              // Settings
              page = UserSettingsPage(
                user: user,
                navBar: navBar,
                onThemeChanged: state.onThemeChanged,
                onLanguageChanged: state.onLanguageChanged,
              );
              break;
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
    final localization = AppLocalizations.of(context)!;

    // Get icon color based on theme
    final destinationColor =
        theme == AppTheme.dark ? Colors.white : Colors.black;

    return NavigationBar(
      onDestinationSelected: onSelected,
      animationDuration: const Duration(milliseconds: 1000),
      selectedIndex: selectedIndex,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        NavigationDestination(
          icon: Icon(
            Icons.home_outlined,
            color: destinationColor,
          ),
          label: localization.home,
        ),
        NavigationDestination(
          icon: Icon(
            Icons.directions_car_filled_rounded,
            color: destinationColor,
          ),
          label: localization.vehicle(2),
        ),
        NavigationDestination(
          icon: Icon(
            Icons.attach_money,
            color: destinationColor,
          ),
          label: localization.sale(2),
        ),
        NavigationDestination(
          icon: Icon(
            Icons.settings,
            color: destinationColor,
          ),
          label: localization.settings,
        ),
      ],
    );
  }
}

/// Widget for info about [PartnerStore]
class PartnerInfoPage extends StatelessWidget {
  /// Constructor
  const PartnerInfoPage({
    required this.user,
    this.navBar,
    this.onStoreEdit,
    super.key,
  });

  /// Reference to [User] object
  final User user;

  /// Page navigation bar
  final Widget? navBar;

  /// Optional callback for when the [PartnerStore] gets edited
  final void Function()? onStoreEdit;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(localization.home),
        actions: [
          IconButton(
            onPressed: () async {
              // Go in edit route
              await context.pushNamed(
                'store_edit',
                extra: {
                  'user': user,
                  'partner_store': user.store!,
                },
              );

              // Call edit callback
              if (onStoreEdit != null) {
                onStoreEdit!();
              }
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      bottomNavigationBar: navBar,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextHeader(label: localization.storeName),
          ),
          InfoText(user.store!.name),
          TextHeader(label: localization.cnpj),
          InfoText(user.store!.cnpj),
          TextHeader(label: localization.autonomyLevel(1)),
          InfoText(user.store!.autonomyLevel.label),
        ],
      ),
    );
  }
}
