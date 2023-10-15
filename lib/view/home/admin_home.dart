import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../entities/autonomy_level.dart';
import '../../entities/partner_store.dart';
import '../../entities/user.dart';
import '../../repositories/autonomy_level_repository.dart';
import '../../repositories/partner_store_repository.dart';
import '../../usecases/autonomy_level_use_case.dart';
import '../../usecases/partner_store_use_case.dart';
import '../info/admin_info.dart';
import '../list/autonomy_level_list.dart';
import '../list/partner_store_list.dart';
import '../unknown_page.dart';
import '../user_settings.dart';

/// Provider for admin home page
class AdminHomeState with ChangeNotifier {
  /// Constructor
  AdminHomeState() {
    unawaited(init());
  }

  /// Which page is selected in the navigation bar
  int navigationBarSelectedIndex = 0;

  /// For getting all [AutonomyLevel]s
  final _autonomyLevelUseCase = const AutonomyLevelUseCase(
    AutonomyLevelRepository(),
  );

  /// For getting all [PartnerStore]s
  final _partnerStoreUseCase = PartnerStoreUseCase(
    const PartnerStoreRepository(),
  );

  /// List of [AutonomyLevel]s
  List<AutonomyLevel>? autonomyLevels;

  /// List of [PartnerStore]s
  List<PartnerStore>? partnerStores;

  /// Total network profit, accounting all sales from all stores
  double? totalNetworkProfit;

  /// Initialize data
  Future<void> init() async {
    // Get stores from database
    final dbStores = await _partnerStoreUseCase.select();
    partnerStores = <PartnerStore>[];
    partnerStores!
      ..clear()
      ..addAll(dbStores);

    // Get autonomy levels
    final dbAutonomyLevels = await _autonomyLevelUseCase.select();
    autonomyLevels = <AutonomyLevel>[];
    autonomyLevels!
      ..clear()
      ..addAll(dbAutonomyLevels);

    // Calculate total network profit
    var total = 0.0;
    for (final store in partnerStores!) {
      for (final sale in store.sales) {
        total += sale.networkProfit;
      }
    }
    totalNetworkProfit = total;

    // Update to show loaded stores and autonomy levels
    notifyListeners();
  }

  /// Method to change NavBar selected item
  Future<void> changePage(int index) async {
    navigationBarSelectedIndex = index;
    notifyListeners();
  }

  /// Called when a PartnerStore gets registered
  Future<void> onPartnerStoreRegister(PartnerStore partnerStore) async {
    partnerStores ??= <PartnerStore>[];
    partnerStores!.add(partnerStore);
    notifyListeners();
  }

  /// Called when a partner store is edited
  void onPartnerStoreEdit(PartnerStore partnerStore) {
    notifyListeners();
  }

  /// Called when an autonomy level gets registered
  Future<void> onAutonomyLevelRegister(AutonomyLevel autonomyLevel) async {
    autonomyLevels ??= <AutonomyLevel>[];
    autonomyLevels!.add(autonomyLevel);
    notifyListeners();
  }

  /// Callback for when an autonomy level gets edited
  void onAutonomyLevelEdit(AutonomyLevel autonomyLevel) {
    notifyListeners();
  }

  /// Callback for when the admin user gets edited
  void onUserEdit() {
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
            theme: user.settings.appTheme,
          );

          // Get page based on current selected index
          late final Widget page;
          switch (state.navigationBarSelectedIndex) {
            case 0:
              page = AdminInfoPage(
                user: user,
                navBar: navBar,
                totalNetworkProfit: state.totalNetworkProfit,
                onUserEdit: state.onUserEdit,
              );
            case 1:
              // Listing of partner stores
              page = PartnerStoreListPage(
                user: user,
                onPartnerStoreRegister: state.onPartnerStoreRegister,
                navBar: navBar,
                onStoreEdit: state.onPartnerStoreEdit,
                items: state.partnerStores,
              );
              break;
            case 2:
              // Listing of partner stores
              page = AutonomyLevelListPage(
                navBar: navBar,
                onRegister: state.onAutonomyLevelRegister,
                onAutonomyLevelEdit: state.onAutonomyLevelEdit,
                items: state.autonomyLevels,
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
            Icons.add_business_outlined,
            color: destinationColor,
          ),
          label: localization.stores,
        ),
        NavigationDestination(
          icon: Icon(
            Icons.stairs_outlined,
            color: destinationColor,
          ),
          label: localization.autonomy,
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
