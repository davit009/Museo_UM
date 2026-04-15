import 'dart:async';

import 'package:flutter/material.dart';
import 'package:museo_app/features/museum/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  static const Color _purple = Color(0xFF4A148C);
  static const Color _darkPurple = Color(0xFF311B92);
  static const Color _gold = Color(0xFFFFD700);

  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleIn;
  late final Animation<Offset> _slideUp;
  late final Animation<double> _glowPulse;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    final fadeCurve = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    final popCurve = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    final glowCurve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(fadeCurve);
    _scaleIn = Tween<double>(begin: 0.92, end: 1).animate(popCurve);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(fadeCurve);
    _glowPulse = Tween<double>(begin: 0.65, end: 1).animate(glowCurve);

    _controller.forward();

    Timer(const Duration(milliseconds: 1400), _goHome);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goHome() {
    if (!mounted || _navigated) {
      return;
    }
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) => const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _AnimatedBackdrop(),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: _fadeIn,
                  child: ScaleTransition(
                    scale: _scaleIn,
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _glowPulse,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _gold.withValues(alpha: 0.18 * _glowPulse.value),
                                    blurRadius: 42,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [_gold, Color(0xFFFFA000), _gold],
                                ).createShader(bounds),
                                child: const Text(
                                  'MUSEO',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 72,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 10,
                                    height: 1,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Universidad de Montemorelos',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 1),
                SlideTransition(
                  position: _slideUp,
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: CustomPaint(
                        size: const Size(double.infinity, 180),
                        painter: _CityscapePainter(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeIn,
                  child: Column(
                    children: [
                      const Text(
                        'Historia, memoria y comunidad',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: LinearProgressIndicator(
                                minHeight: 4,
                                value: _controller.value,
                                backgroundColor: Colors.white.withValues(alpha: 0.16),
                                valueColor: const AlwaysStoppedAnimation<Color>(_gold),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Cargando experiencia...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBackdrop extends StatefulWidget {
  const _AnimatedBackdrop();

  @override
  State<_AnimatedBackdrop> createState() => _AnimatedBackdropState();
}

class _AnimatedBackdropState extends State<_AnimatedBackdrop> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4A148C), Color(0xFF311B92)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -80 + (t * 18),
                left: -60,
                child: _softOrb(const Color(0xFFFFD54F).withValues(alpha: 0.18), 180),
              ),
              Positioned(
                bottom: -100 - (t * 16),
                right: -50,
                child: _softOrb(Colors.white.withValues(alpha: 0.09), 220),
              ),
              Positioned(
                top: 140 + (t * 22),
                right: 20,
                child: _softOrb(const Color(0xFF7E57C2).withValues(alpha: 0.18), 120),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _BackdropLinesPainter(progress: t),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _softOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.02)],
        ),
      ),
    );
  }
}

class _BackdropLinesPainter extends CustomPainter {
  final double progress;

  _BackdropLinesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final offset = size.height * 0.12 * progress;
    for (int i = 0; i < 4; i++) {
      final y = size.height * 0.18 + i * 48 + offset;
      canvas.drawLine(Offset(24, y), Offset(size.width - 24, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BackdropLinesPainter oldDelegate) => oldDelegate.progress != progress;
}

class _CityscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintYellow = Paint()..color = const Color(0xFFFFD700);
    final paintTeal = Paint()..color = const Color(0xFF7E57C2).withValues(alpha: 0.62);
    final paintDark = Paint()..color = const Color(0xFF311B92).withValues(alpha: 0.55);

    final groundShadow = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Color(0xAA160A33)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.86, size.width, size.height * 0.14), groundShadow);

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.03, size.height * 0.35, size.width * 0.07, size.height * 0.52),
      paintTeal,
    );
    _drawWindows(canvas, size.width * 0.04, size.height * 0.4, 2, 3, paintDark);

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.12, size.height * 0.18, size.width * 0.09, size.height * 0.69),
      paintYellow,
    );
    _drawWindows(canvas, size.width * 0.13, size.height * 0.23, 2, 4, paintDark);

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.28, size.height * 0.28, size.width * 0.44, size.height * 0.58),
      paintYellow,
    );

    final roofPath = Path()
      ..moveTo(size.width * 0.26, size.height * 0.28)
      ..lineTo(size.width * 0.5, size.height * 0.05)
      ..lineTo(size.width * 0.74, size.height * 0.28)
      ..close();
    canvas.drawPath(roofPath, paintYellow);

    for (int i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * 0.31 + i * size.width * 0.1,
          size.height * 0.58,
          size.width * 0.04,
          size.height * 0.28,
        ),
        paintDark,
      );
    }

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.77, size.height * 0.2, size.width * 0.1, size.height * 0.68),
      paintTeal,
    );
    _drawWindows(canvas, size.width * 0.78, size.height * 0.25, 2, 4, paintDark);

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.89, size.height * 0.4, size.width * 0.08, size.height * 0.48),
      paintYellow,
    );
    _drawWindows(canvas, size.width * 0.905, size.height * 0.45, 1, 3, paintDark);

    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.92, size.width, size.height * 0.08),
      Paint()..color = const Color(0xFF311B92),
    );
  }

  void _drawWindows(Canvas canvas, double startX, double startY, int cols, int rows, Paint paint) {
    const double winW = 6;
    const double winH = 8;
    const double gapX = 9;
    const double gapY = 12;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawRect(
          Rect.fromLTWH(startX + c * gapX, startY + r * gapY, winW, winH),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}