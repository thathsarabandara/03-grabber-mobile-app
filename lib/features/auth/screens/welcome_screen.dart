import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(
                LucideIcons.bot,
                size: 100,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to Grabber',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Join the platform and start controlling robots intelligently.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              CustomButton(
                text: 'Login',
                onPressed: () => context.go('/login'),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Create Account',
                isPrimary: false,
                onPressed: () => context.go('/register'),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.go('/dashboard'),
                child: Text(
                  'Continue as Guest',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
