import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/premium_widgets.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0, height: 400,
            child: CustomPaint(painter: HeaderWavePainter()),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                children: [
                  const Spacer(),
                  SlideFade(
                    animation: _animController,
                    delay: 0.2,
                    child: Container(
                      padding: const EdgeInsets.only(left: 30 , right: 30,top: 25,bottom: 25) ,
                      decoration: BoxDecoration(
                        boxShadow: [BoxShadow(color: const Color(0xFF155EEF).withValues(alpha: 0.2), blurRadius: 40)],
                      ),
                      child: Image.asset(
                        "assets/Grabber.png",
                        fit: BoxFit.contain,
                        height: 200, // Adjust size as needed
                        width: 200,  // Adjust size as needed
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
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
                        children: [
                          const Text(
                            'Welcome to Grabber',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1D2939), letterSpacing: -1),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Join the platform and start controlling your robots intelligently from anywhere in the world.',
                            style: TextStyle(fontSize: 15, color: Color(0xFF64748B), height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          BouncingCard(
                            onTap: () => context.go('/login'),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                color: const Color(0xFF155EEF),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: const Color(0xFF155EEF).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                              ),
                              child: const Center(child: Text('Login to Account', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))),
                            ),
                          ),
                          const SizedBox(height: 16),
                          BouncingCard(
                            onTap: () => context.go('/register'),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(child: Text('Create Account', style: TextStyle(color: Color(0xFF1D2939), fontSize: 16, fontWeight: FontWeight.w800))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
