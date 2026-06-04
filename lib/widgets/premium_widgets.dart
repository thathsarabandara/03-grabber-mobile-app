import 'package:flutter/material.dart';

// Organic Background Painter
class HeaderWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4F46E5), Color(0xFF155EEF)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRect(rect, paint);
    final blob1 = Paint()..color = const Color(0xFF06B6D4).withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.3), 150, blob1);
    final blob2 = Paint()..color = const Color(0xFF8B5CF6).withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.5), 180, blob2);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Slide Fade Animation
class SlideFade extends StatelessWidget {
  final Animation<double> animation;
  final double delay;
  final Widget child;

  const SlideFade({super.key, required this.animation, required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: Interval(delay, 1.0, curve: Curves.easeOutCubic));
    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) => Opacity(
        opacity: curved.value,
        child: Transform.translate(offset: Offset(0, 40 * (1 - curved.value)), child: child),
      ),
      child: child,
    );
  }
}

// Bouncing Card for Interactions
class BouncingCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const BouncingCard({super.key, required this.child, this.onTap});

  @override
  State<BouncingCard> createState() => _BouncingCardState();
}

class _BouncingCardState extends State<BouncingCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        if (widget.onTap != null) widget.onTap!();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
