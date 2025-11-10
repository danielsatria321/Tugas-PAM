import 'package:flutter/material.dart';

class FadeSlideDownAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double offsetY; // seberapa jauh turun
  final Curve curve;

  const FadeSlideDownAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 700),
    this.delay = Duration.zero,
    this.offsetY = 40.0,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<FadeSlideDownAnimation> createState() => _FadeSlideDownAnimationState();
}

class _FadeSlideDownAnimationState extends State<FadeSlideDownAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -widget.offsetY / 100), // mulai dari sedikit di atas
      end: Offset.zero, // berhenti di posisi normal
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    // Jalankan animasi setelah delay
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
