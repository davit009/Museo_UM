import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const Color _darkNavy = Color(0xFF1A2B4A);
  static const Color _teal = Color(0xFF1B9E8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_teal, _darkNavy],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo MUSEO con gradiente
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFF4FC3F7),
                    Color(0xFFEFBE3D),
                    Color(0xFF4DB6AC),
                  ],
                ).createShader(bounds),
                child: const Text(
                  'MUSEO',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 10,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Universidad de Mendoza',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  letterSpacing: 3,
                ),
              ),
              const Spacer(flex: 1),
              // Ilustración ciudad
              CustomPaint(
                size: const Size(double.infinity, 160),
                painter: _CityscapePainter(),
              ),
              const Spacer(flex: 1),
              // Botones
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _irAlHome(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _darkNavy,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'EXPLORAR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _irAlHome(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'INGRESAR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _irAlHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
}

class _CityscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintYellow = Paint()..color = const Color(0xFFEFBE3D);
    final paintTeal = Paint()..color = const Color(0xFF4DB6AC).withValues(alpha: 0.6);
    final paintDark = Paint()..color = const Color(0xFF1A2B4A).withValues(alpha: 0.5);

    // Edificio izquierda
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.03, size.height * 0.35, size.width * 0.07, size.height * 0.65),
      paintTeal,
    );
    // Ventanas edificio izq
    _drawWindows(canvas, size.width * 0.04, size.height * 0.4, 2, 3, paintDark);

    // Edificio alto izquierda
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.12, size.height * 0.15, size.width * 0.09, size.height * 0.85),
      paintYellow,
    );
    _drawWindows(canvas, size.width * 0.13, size.height * 0.2, 2, 4, paintDark);

    // MUSEO - edificio central con columnas
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.28, size.height * 0.3, size.width * 0.44, size.height * 0.7),
      paintYellow,
    );
    // Triangulo techo museo
    final roofPath = Path()
      ..moveTo(size.width * 0.26, size.height * 0.3)
      ..lineTo(size.width * 0.5, size.height * 0.05)
      ..lineTo(size.width * 0.74, size.height * 0.3)
      ..close();
    canvas.drawPath(roofPath, paintYellow);
    // Columnas museo
    for (int i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * 0.31 + i * size.width * 0.1,
          size.height * 0.6,
          size.width * 0.04,
          size.height * 0.4,
        ),
        paintDark,
      );
    }

    // Edificio derecha alto
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.77, size.height * 0.2, size.width * 0.1, size.height * 0.8),
      paintTeal,
    );
    _drawWindows(canvas, size.width * 0.78, size.height * 0.25, 2, 4, paintDark);

    // Edificio derecha bajo
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.89, size.height * 0.4, size.width * 0.08, size.height * 0.6),
      paintYellow,
    );
    _drawWindows(canvas, size.width * 0.905, size.height * 0.45, 1, 3, paintDark);

    // Suelo
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.98, size.width, size.height * 0.02),
      Paint()..color = const Color(0xFF1A2B4A),
    );
  }

  void _drawWindows(Canvas canvas, double startX, double startY,
      int cols, int rows, Paint paint) {
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
