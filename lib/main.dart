import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/main_shell.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/robots/screens/robots_screen.dart';
import 'features/control/screens/control_screen.dart';
import 'features/control/screens/manual_control_screen.dart';
import 'features/control/screens/ai_control_screen.dart';
import 'features/media/screens/media_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'widgets/premium_widgets.dart';

void main() {
  runApp(const ProviderScope(child: GrabberApp()));
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Register Screen'))),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/robots',
            builder: (context, state) => const RobotsScreen(),
          ),
          GoRoute(
            path: '/control',
            builder: (context, state) => const ControlScreen(),
          ),
          GoRoute(
            path: '/media',
            builder: (context, state) => const MediaScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/ai-control',
        builder: (context, state) => const AiControlScreen(),
      ),
      GoRoute(
        path: '/manual-control',
        builder: (context, state) => const ManualControlScreen(),
      ),
    ],
  );
});

class GrabberApp extends ConsumerWidget {
  const GrabberApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Grabber',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _animController.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: HeaderWavePainter()),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlideFade(
                  animation: _animController,
                  delay: 0.1,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(Icons.precision_manufacturing_rounded, size: 80, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 32),
                SlideFade(
                  animation: _animController,
                  delay: 0.3,
                  child: const Text('Grabber', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2)),
                ),
                const SizedBox(height: 8),
                SlideFade(
                  animation: _animController,
                  delay: 0.5,
                  child: Text('Control. Automate. Innovate.', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
