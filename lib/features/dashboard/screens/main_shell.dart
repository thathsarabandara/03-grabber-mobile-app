import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/dashboard')) {
      return 0;
    }
    if (location.startsWith('/robots')) {
      return 1;
    }
    if (location.startsWith('/control')) {
      return 2;
    }
    if (location.startsWith('/media')) {
      return 3;
    }
    if (location.startsWith('/profile')) {
      return 4;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/robots');
        break;
      case 2:
        context.go('/control');
        break;
      case 3:
        context.go('/media');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _onItemTapped(index, context),
        backgroundColor: theme.colorScheme.surface,
        indicatorColor: theme.colorScheme.primaryContainer,
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.layoutDashboard),
            selectedIcon: Icon(LucideIcons.layoutDashboard, color: Colors.white),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.cpu),
            selectedIcon: Icon(LucideIcons.cpu, color: Colors.white),
            label: 'Robots',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.gamepad2),
            selectedIcon: Icon(LucideIcons.gamepad2, color: Colors.white),
            label: 'Control',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.image),
            selectedIcon: Icon(LucideIcons.image, color: Colors.white),
            label: 'Media',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.user),
            selectedIcon: Icon(LucideIcons.user, color: Colors.white),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
