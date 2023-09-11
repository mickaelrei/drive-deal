import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'register_store.dart';

/// Provider for admin home page
class AdminHomeState with ChangeNotifier {
  /// Which page is selected in the navigation bar
  int navigationBarSelectedIndex = 0;

  /// Method to change NavBar selected item
  void changePage(int index) {
    navigationBarSelectedIndex = index;

    // Update widget
    notifyListeners();
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
        builder: (context, state, child) {
          // Get page based on current selected index
          late Widget page;
          switch (state.navigationBarSelectedIndex) {
            case 0:
              page = const Center(
                child: Text('Welcome to the Home Page, Admin!'),
              );
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
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('Drive Deal'),
            ),
            body: page,
            bottomNavigationBar: NavigationBar(
              onDestinationSelected: (index) {
                state.changePage(index);
              },
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
