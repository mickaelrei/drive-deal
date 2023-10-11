import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../entities/autonomy_level.dart';
import '../../entities/partner_store.dart';
import '../../entities/user.dart';

import '../../repositories/autonomy_level_repository.dart';
import '../../repositories/partner_store_repository.dart';
import '../../usecases/autonomy_level_use_case.dart';
import '../../usecases/partner_store_use_case.dart';
import '../../utils/forms.dart';

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

  /// List of [AutonomyLevel]s
  late Future<List<AutonomyLevel>> autonomyLevels;

  /// For getting all [PartnerStore]s
  final _partnerStoreUseCase = PartnerStoreUseCase(
    const PartnerStoreRepository(),
  );

  /// List of [PartnerStore]s
  late Future<List<PartnerStore>> partnerStores;

  /// Initialize data
  Future<void> init() async {
    partnerStores = _partnerStoreUseCase.select();
    autonomyLevels = _autonomyLevelUseCase.select();
  }

  /// Method to change NavBar selected item
  Future<void> changePage(int index) async {
    navigationBarSelectedIndex = index;
    notifyListeners();
  }

  /// Called when a PartnerStore gets registered
  Future<void> onPartnerStoreRegister(PartnerStore partnerStore) async {
    partnerStores = _partnerStoreUseCase.select();
    notifyListeners();
  }

  /// Called when an autonomy level gets registered
  Future<void> onAutonomyLevelRegister(AutonomyLevel autonomyLevel) async {
    autonomyLevels = _autonomyLevelUseCase.select();
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
                theme: user.settings.appTheme,
                onUserEdit: state.onUserEdit,
              );
            case 1:
              // Listing of partner stores
              page = PartnerStoreListPage(
                theme: user.settings.appTheme,
                onPartnerStoreRegister: state.onPartnerStoreRegister,
                navBar: navBar,
                items: state.partnerStores,
              );
              break;
            case 2:
              // Listing of partner stores
              page = AutonomyLevelListPage(
                navBar: navBar,
                theme: user.settings.appTheme,
                onRegister: state.onAutonomyLevelRegister,
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

/// Widget for info about [PartnerStore]
class AdminInfoPage extends StatelessWidget {
  /// Constructor
  const AdminInfoPage({
    required this.user,
    this.navBar,
    this.onUserEdit,
    this.theme = UserSettings.defaultAppTheme,
    super.key,
  });

  /// Reference to [User] object
  final User user;

  /// Page navigation bar
  final Widget? navBar;

  /// Optional callback for when the [PartnerStore] gets edited
  final void Function()? onUserEdit;

  /// Theme
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Admin Home'),
      ),
      bottomNavigationBar: navBar,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Go in edit route
          await Navigator.of(context).pushNamed(
            '/user_edit',
            arguments: {
              'user': user,
              'theme': theme,
              'on_edit': onUserEdit,
            },
          );
        },
        child: const Icon(Icons.edit),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextHeader(label: 'User name:'),
            InfoText(user.name!),
          ],
        ),
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
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.add_business_outlined,
            color: destinationColor,
          ),
          label: 'Stores',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.stairs_outlined,
            color: destinationColor,
          ),
          label: 'Autonomy',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.settings,
            color: destinationColor,
          ),
          label: 'Settings',
        ),
      ],
    );
  }
}
