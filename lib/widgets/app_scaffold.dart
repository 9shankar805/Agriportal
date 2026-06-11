import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import './app_navigation.dart';

class AppScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      // Key on currentIndex forces the nav to rebuild whenever the branch
      // changes, which re-evaluates the selected tab highlight correctly.
      bottomNavigationBar: AppNavigation(
        key: ValueKey(navigationShell.currentIndex),
        navigationShell: navigationShell,
      ),
    );
  }
}
