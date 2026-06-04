import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/premium_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animController;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Control Anywhere',
      'description': 'Securely connect and control your robotic devices from anywhere using low-latency cloud infrastructure.',
      'image': 'assets/control.png',
    },
    {
      'title': 'Live Telemetry',
      'description': 'Monitor your robot\'s health, battery, and sensor readings in real-time with stunning HD visuals.',
      'image': 'assets/telemetry.png',
    },
    {
      'title': 'Agentic AI',
      'description': 'Automate complex tasks using advanced artificial intelligence and computer vision models.',
      'image': 'assets/agentic.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF155EEF),
      body: Stack(
        children: [
          // Blue wave background at the top
          Positioned(
            top: 0, left: 0, right: 0, height: size.height * 0.7, // Increased blue area
            child: CustomPaint(painter: HeaderWavePainter()),
          ),
          
          // Stationary White Sheet at the bottom
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: size.height * 0.35, // Covers bottom 42%
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 40, offset: Offset(0, -10)),
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4)),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: TextButton(
                      onPressed: () => context.go('/welcome'),
                      child: const Text('Skip', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      _animController.forward(from: 0);
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          // Top part: Icon over blue background
                          Expanded(
                            flex: 55, // Takes up the top space matching the blue area
                            child: Center(
                              child: SlideFade(
                                animation: _animController,
                                delay: 0.1,
                                child: Container(
                                  padding: const EdgeInsets.all(40),
                                  decoration: BoxDecoration(
                                  ),
                                  child: Image(
                                    image: AssetImage(_pages[index]['image'] as String),
                                    height: 400,
                                    width: 400,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          // Bottom part: Text over white sheet
                          Expanded(
                            flex: 32, // Takes up the bottom space matching the white sheet
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SlideFade(
                                    animation: _animController,
                                    delay: 0.2,
                                    child: Text(
                                      _pages[index]['title'] as String,
                                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1D2939), letterSpacing: -1),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SlideFade(
                                    animation: _animController,
                                    delay: 0.3,
                                    child: Text(
                                      _pages[index]['description'] as String,
                                      style: const TextStyle(fontSize: 15, color: Color(0xFF64748B), height: 1.5),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                
                // Bottom navigation bar over the white sheet
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? const Color(0xFF155EEF) : const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      BouncingCard(
                        onTap: () {
                          if (_currentPage == _pages.length - 1) {
                            context.go('/welcome');
                          } else {
                            _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF155EEF),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: const Color(0xFF155EEF).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPage == _pages.length - 1 ? 'Start' : 'Next',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
