import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: const Icon(LucideIcons.user, size: 48, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(height: 16),
                  Text('John Doe', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text('john.doe@example.com', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Settings Sections
            _buildSectionHeader('Account'),
            _buildListTile(context, LucideIcons.edit, 'Edit Profile'),
            _buildListTile(context, LucideIcons.key, 'Change Password'),
            _buildListTile(context, LucideIcons.shield, 'Security & Sessions'),
            
            const SizedBox(height: 16),
            _buildSectionHeader('Devices'),
            _buildListTile(context, LucideIcons.cpu, 'Manage Robots'),
            _buildListTile(context, LucideIcons.plusCircle, 'Pair New Device'),
            _buildListTile(context, LucideIcons.settings, 'Robot Preferences'),
            
            const SizedBox(height: 16),
            _buildSectionHeader('App Settings'),
            _buildListTile(context, LucideIcons.moon, 'Theme', trailing: const Text('System')),
            _buildListTile(context, LucideIcons.globe, 'Language', trailing: const Text('English')),
            _buildListTile(context, LucideIcons.bell, 'Notifications'),
            
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => context.go('/welcome'),
                  icon: const Icon(LucideIcons.logOut, color: AppTheme.danger),
                  label: const Text('Logout', style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold, fontSize: 16)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: AppTheme.danger.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.textSecondaryLight,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: trailing ?? const Icon(LucideIcons.chevronRight, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      onTap: () {},
    );
  }
}
