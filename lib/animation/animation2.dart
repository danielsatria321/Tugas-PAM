import 'package:flutter/material.dart';

class SlideLeftRightLoop extends StatefulWidget {
  final Widget child;
  final Duration enterDuration;
  final Duration loopDuration;
  final double moveDistance;
  final Duration? delay;
  final double startOffsetX; // posisi awal dari kiri (px)

  const SlideLeftRightLoop({
    super.key,
    required this.child,
    this.enterDuration = const Duration(milliseconds: 800),
    this.loopDuration = const Duration(seconds: 2),
    this.moveDistance = 20.0,
    this.delay,
    this.startOffsetX = -150.0, // default posisi awal dari kiri
  });

  @override
  State<SlideLeftRightLoop> createState() => _SlideLeftRightLoopState();
}

class _SlideLeftRightLoopState extends State<SlideLeftRightLoop>
    with TickerProviderStateMixin {
  AnimationController? _enterController;
  AnimationController? _loopController;

  Animation<Offset>? _slideInAnimation;
  Animation<double>? _loopAnimation;

  bool _isLooping = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Jalankan animasi hanya sekali
    if (!_initialized) {
      _initialized = true;
      _startEnterAnimation();
    }
  }

  Future<void> _startEnterAnimation() async {
    if (widget.delay != null) {
      await Future.delayed(widget.delay!);
    }

    _enterController = AnimationController(
      vsync: this,
      duration: widget.enterDuration,
    );

    final screenWidth = MediaQuery.of(context).size.width;

    _slideInAnimation =
        Tween<Offset>(
          begin: Offset(widget.startOffsetX / screenWidth, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _enterController!,
            curve: Curves.easeOutCubic,
          ),
        );

    await _enterController!.forward();
    await Future.delayed(const Duration(milliseconds: 200));

    _startLoopAnimation();
  }

  void _startLoopAnimation() {
    // hentikan dan dispose enterController dengan aman
    if (_enterController != null) {
      if (_enterController!.isAnimating) {
        _enterController!.stop();
      }
      _enterController!.dispose();
      _enterController = null; // penting agar tidak di-dispose lagi nanti
    }

    _loopController = AnimationController(
      vsync: this,
      duration: widget.loopDuration,
    )..repeat(reverse: true);

    _loopAnimation =
        Tween<double>(
          begin: -widget.moveDistance,
          end: widget.moveDistance,
        ).animate(
          CurvedAnimation(parent: _loopController!, curve: Curves.easeInOut),
        );

    setState(() {
      _isLooping = true;
    });
  }

  @override
  void dispose() {
    try {
      _enterController?.dispose();
    } catch (_) {}
    try {
      _loopController?.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLooping) {
      return SlideTransition(
        position:
            _slideInAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _loopController!,
      builder: (context, child) {
        final dx = _loopAnimation?.value ?? 0.0;
        return Transform.translate(offset: Offset(dx, 0), child: widget.child);
      },
    );
  }
}
