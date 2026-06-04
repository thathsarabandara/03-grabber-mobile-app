import 'package:flutter/material.dart';

class PatternBackground extends StatelessWidget {
  final Widget child;

  const PatternBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC), // slate-50 background for light theme
      ),
      child: Stack(
        children: [
          // Dot pattern
          Positioned.fill(
            child: CustomPaint(
              painter: DotPatternPainter(),
            ),
          ),
          // Ambient gradients for modern vibe
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
              ),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.5) // slate-300
      ..strokeWidth = 1.0;

    const spacing = 24.0;
    
    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
