import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../widgets/premium_widgets.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _showBiometricButton = false;
  bool _hasLoggedInBefore = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _animController.forward();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final authNotifier = ref.read(authProvider.notifier);
    final isEnabled = await authNotifier.isBiometricsEnabled();
    final hasCredentials = await authNotifier.hasSavedCredentials();
    const storage = FlutterSecureStorage();
    final hasLoggedIn = await storage.read(key: 'has_logged_in_before') == 'true';
    if (mounted) {
      setState(() {
        _showBiometricButton = isEnabled && hasCredentials;
        _hasLoggedInBefore = hasLoggedIn;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0, height: 700,
            child: CustomPaint(painter: HeaderWavePainter()),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_hasLoggedInBefore)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    child: IconButton(
                      icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                      onPressed: () => context.go('/welcome'),
                    ),
                  )
                else
                  const SizedBox(height: 48),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 24),
                                  SlideFade(
                                    animation: _animController,
                                    delay: 0.1,
                                    child: const Text(
                                      'Welcome Back',
                                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SlideFade(
                                    animation: _animController,
                                    delay: 0.2,
                                    child: const Text(
                                      'Sign in to control your robots.',
                                      style: TextStyle(fontSize: 16, color: Colors.white70),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 40),
                                    child: SlideFade(
                                      animation: _animController,
                                      delay: 0.05,
                                      child: Center(
                                        child: Image.asset(
                                          "assets/login.png",
                                          height: 300,
                                          width: 300, 
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  const SizedBox(height: 24),
                                  SlideFade(
                                    animation: _animController,
                                    delay: 0.3,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(32),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(40),
                                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 30, offset: const Offset(0, 10))],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildTextField(
                                            controller: _emailController,
                                            label: 'EMAIL ADDRESS',
                                            hint: 'operator@grabber.local',
                                            icon: LucideIcons.mail,
                                          ),
                                          const SizedBox(height: 24),
                                          _buildTextField(
                                            controller: _passwordController,
                                            label: 'PASSWORD',
                                            hint: '••••••••',
                                            icon: LucideIcons.lock,
                                            isPassword: true,
                                          ),
                                          const SizedBox(height: 16),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                              onPressed: () => context.go('/forgot-password'), // TODO: Forgot password
                                              child: const Text(
                                                'Forgot Password?',
                                                style: TextStyle(color: Color(0xFF155EEF), fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 32),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: BouncingCard(
                                                  onTap: () async {
                                                    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                                                      return;
                                                    }
                                                    final success = await ref.read(authProvider.notifier).login(
                                                      _emailController.text,
                                                      _passwordController.text,
                                                    );
                                                    if (success && mounted) {
                                                      context.go('/dashboard');
                                                    } else if (mounted) {
                                                      final error = ref.read(authProvider).error;
                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Login failed')));
                                                    }
                                                  },
                                                  child: Container(
                                                    width: double.infinity,
                                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF155EEF),
                                                      borderRadius: BorderRadius.circular(20),
                                                      boxShadow: [BoxShadow(color: const Color(0xFF155EEF).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                                                    ),
                                                    child: Center(
                                                      child: authState.isLoading 
                                                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                                        : const Text('Login', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (_showBiometricButton) ...[
                                                const SizedBox(width: 12),
                                                BouncingCard(
                                                  onTap: () async {
                                                    final success = await ref.read(authProvider.notifier).biometricLogin();
                                                    if (success && mounted) {
                                                      context.go('/dashboard');
                                                    } else if (mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(content: Text('Biometric authentication failed or cancelled')),
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.all(18),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFEFF8FF),
                                                      borderRadius: BorderRadius.circular(20),
                                                      border: Border.all(color: const Color(0xFFD1E9FF), width: 1.5),
                                                    ),
                                                    child: const Icon(
                                                      Icons.fingerprint_rounded,
                                                      color: Color(0xFF155EEF),
                                                      size: 24,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Text('Don\'t have an account?', style: TextStyle(color: Color(0xFF64748B))),
                                              TextButton(
                                                onPressed: () => context.go('/register'),
                                                child: const Text('Sign Up', style: TextStyle(color: Color(0xFF155EEF), fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1.5),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(color: Color(0xFF1D2939), fontSize: 14, fontWeight: FontWeight.w600),
            obscureText: isPassword && _obscurePassword,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500),
              prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 18),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                        color: const Color(0xFF94A3B8),
                        size: 18,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
