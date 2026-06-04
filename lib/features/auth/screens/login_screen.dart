import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../widgets/premium_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _animController.forward();
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: IconButton(
                    icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                    onPressed: () => context.go('/welcome'),
                  ),
                ),
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
                                            label: 'Email',
                                            hint: 'john.doe@example.com',
                                            icon: LucideIcons.mail,
                                          ),
                                          const SizedBox(height: 24),
                                          _buildTextField(
                                            controller: _passwordController,
                                            label: 'Password',
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
                                          BouncingCard(
                                            onTap: () => context.go('/dashboard'),
                                            child: Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.symmetric(vertical: 18),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF155EEF),
                                                borderRadius: BorderRadius.circular(20),
                                                boxShadow: [BoxShadow(color: const Color(0xFF155EEF).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                                              ),
                                              child: const Center(child: Text('Login', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))),
                                            ),
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
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1D2939)),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.black),
            obscureText: isPassword && _obscurePassword,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                        color: const Color(0xFF64748B),
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
