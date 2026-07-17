import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/otp_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/dashboard/screens/main_shell.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/dashboard/screens/telemetry_screen.dart';
import 'features/dashboard/screens/notification_details_screen.dart';
import 'features/robots/screens/robots_screen.dart';
import 'features/control/screens/control_screen.dart';
import 'features/control/screens/manual_control_screen.dart';
import 'features/control/screens/ai_control_screen.dart';
import 'features/media/screens/media_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/edit_profile_screen.dart';
import 'features/profile/screens/sessions_screen.dart';
import 'features/profile/screens/change_password_screen.dart';
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
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) => OtpScreen(email: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
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
          GoRoute(
            path: '/telemetry',
            builder: (context, state) => const TelemetryScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/sessions',
        builder: (context, state) => const SessionsScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/ai-control',
        builder: (context, state) => const AiControlScreen(),
      ),
      GoRoute(
        path: '/manual-control',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ManualControlScreen(
            robotId: extra['robotId'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/notification-details',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return NotificationDetailsScreen(
            title: extra['title'] ?? 'Notification',
            message: extra['message'] ?? 'No details available.',
            icon: extra['icon'] ?? Icons.info,
            color: extra['color'] ?? Colors.blue,
            time: extra['time'] ?? 'Just now',
          );
        },
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

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _animController.forward();
    _requestPermissionsAndNavigate();
  }

  Future<void> _requestPermissionsAndNavigate() async {
    // Wait briefly to let the splash animation start
    await Future.delayed(const Duration(milliseconds: 500));

    // Request permissions up front
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    // Ensure the splash screen stays for a bit
    await Future.delayed(const Duration(milliseconds: 2000));

    if (mounted) {
      const storage = FlutterSecureStorage();
      final hasLoggedInBefore = await storage.read(key: 'has_logged_in_before') == 'true';
      final biometricsEnabled = await storage.read(key: 'biometrics_enabled') == 'true';
      final hasToken = await storage.read(key: 'auth_token') != null;

      if (!hasLoggedInBefore) {
        context.go('/onboarding');
      } else {
        if (biometricsEnabled) {
          final success = await ref.read(authProvider.notifier).biometricLogin();
          if (success && mounted) {
            context.go('/dashboard');
          } else if (mounted) {
            context.go('/login');
          }
        } else {
          if (hasToken) {
            context.go('/dashboard');
          } else {
            context.go('/login');
          }
        }
      }
    }
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
                  delay: 0.3,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                    ),
                    child: Image.asset("assets/Grabber.png",
                      fit: BoxFit.contain,
                      height: 300,
                      width: 300,
                      ),
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
