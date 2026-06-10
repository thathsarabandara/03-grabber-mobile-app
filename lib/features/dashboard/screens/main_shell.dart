import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF8FAFC),
      body: widget.child,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFF155EEF).withValues(alpha: 0.05),
                blurRadius: 30,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Home', 0, selectedIndex, context),
              _buildNavItem(Icons.precision_manufacturing_outlined, Icons.precision_manufacturing_rounded, 'Robots', 1, selectedIndex, context),
              _buildNavItem(Icons.gamepad_outlined, Icons.gamepad_rounded, 'Control', 2, selectedIndex, context),
              _buildNavItem(Icons.perm_media_outlined, Icons.perm_media_rounded, 'Media', 3, selectedIndex, context),
              _buildNavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile', 4, selectedIndex, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, String label, int index, int selectedIndex, BuildContext context) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index, context),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 12 : 8, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF155EEF).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon, 
              color: isSelected ? const Color(0xFF155EEF) : const Color(0xFF94A3B8), 
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Color(0xFF155EEF), fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: -0.2),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
