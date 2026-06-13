import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../widgets/premium_widgets.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
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
                                  SlideFade(
                                    animation: _animController,
                                    delay: 0.1,
                                    child: const Text(
                                      'Create Account',
                                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SlideFade(
                                    animation: _animController,
                                    delay: 0.2,
                                    child: const Text(
                                      'Join Grabber and control your robots.',
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
                                          "assets/register.png",
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
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildTextField(
                                                  controller: _firstNameController,
                                                  label: 'FIRST NAME',
                                                  hint: 'John',
                                                  icon: LucideIcons.user,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: _buildTextField(
                                                  controller: _lastNameController,
                                                  label: 'LAST NAME',
                                                  hint: 'Doe',
                                                  icon: LucideIcons.user,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          _buildTextField(
                                            controller: _emailController,
                                            label: 'EMAIL ADDRESS',
                                            hint: 'operator@grabber.local',
                                            icon: LucideIcons.mail,
                                          ),
                                          const SizedBox(height: 20),
                                          _buildTextField(
                                            controller: _phoneController,
                                            label: 'PHONE NUMBER',
                                            hint: '+1 (555) 000-0000',
                                            icon: LucideIcons.phone,
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildTextField(
                                                  controller: _passwordController,
                                                  label: 'PASSWORD',
                                                  hint: '••••••••',
                                                  icon: LucideIcons.lock,
                                                  isPassword: true,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: _buildTextField(
                                                  controller: _passwordConfirmController,
                                                  label: 'CONFIRM',
                                                  hint: '••••••••',
                                                  icon: LucideIcons.lock,
                                                  isPassword: true,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 32),
                                          BouncingCard(
                                            onTap: () async {
                                              if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
                                                return;
                                              }
                                              if (_passwordController.text != _passwordConfirmController.text) {
                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
                                                return;
                                              }
                                              
                                              final success = await ref.read(authProvider.notifier).register(
                                                firstName: _firstNameController.text.trim(),
                                                lastName: _lastNameController.text.trim(),
                                                email: _emailController.text.trim(),
                                                password: _passwordController.text,
                                                phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
                                              );
                                              
                                              if (success && mounted) {
                                                context.go('/otp', extra: _emailController.text);
                                              } else if (mounted) {
                                                final error = ref.read(authProvider).error;
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Registration failed')));
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
                                                  : const Text('Sign Up', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Text('Already have an account?', style: TextStyle(color: Color(0xFF64748B))),
                                              TextButton(
                                                onPressed: () => context.go('/login'),
                                                child: const Text('Login', style: TextStyle(color: Color(0xFF155EEF), fontWeight: FontWeight.bold)),
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
