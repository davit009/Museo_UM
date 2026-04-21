import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:museo_app/features/museum/screens/intro_historia_screen.dart';
import 'package:museo_app/features/museum/screens/etapas_screen.dart';
import 'package:museo_app/features/museum/screens/jubilados_screen.dart';
import 'package:museo_app/features/museum/screens/images_screen.dart';
import 'package:museo_app/features/museum/screens/musica_screen.dart';
import 'package:museo_app/features/museum/screens/datos_curiosos_screen.dart';
import 'package:museo_app/features/museum/screens/informacion_screen.dart';
import 'package:museo_app/features/museum/screens/como_llegar_screen.dart';
import 'package:museo_app/features/social/screens/muro_screen.dart';
import 'package:museo_app/features/auth/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:museo_app/features/social/screens/profile_screen.dart';
import 'package:museo_app/features/social/screens/social_hub_screen.dart';
import 'package:museo_app/features/admin/screens/admin_dashboard_screen.dart';
import 'package:museo_app/features/social/screens/notifications_screen.dart';
import 'package:museo_app/features/admin/services/admin_service.dart';
import 'package:museo_app/core/services/push_notification_service.dart';

// ── Ilustraciones prominentes por sección ─────────────────────────────────
class _SectionArtPainter extends CustomPainter {
  final int index;
  _SectionArtPainter(this.index);

  @override
  void paint(Canvas canvas, Size size) {
    switch (index) {
      case 0: { _historia(canvas, size);    break; } // Historia (tiene imagen, no se usa)
      case 1: { _etapas(canvas, size);      break; } // Las Etapas
      case 2: { _jubilados(canvas, size);   break; } // Jubilados
      case 3: { _galeria(canvas, size);     break; } // Galerías
      case 4: { _musica(canvas, size);      break; } // Música
      case 5: { _curiosos(canvas, size);    break; } // Datos Curiosos
      case 6: { _informacion(canvas, size); break; } // Información
      case 7: { _comoLlegar(canvas, size);  break; } // Cómo Llegar (tiene imagen)
      case 8: { _socialRed(canvas, size);   break; } // Comunidad
    }
  }

  Paint _p(double alpha, {double width = 1.5, bool fill = false}) => Paint()
    ..color = Colors.white.withValues(alpha: alpha)
    ..strokeWidth = width
    ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke
    ..isAntiAlias = true;

  // Historia — libro abierto grande
  void _historia(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height * 0.52;
    final w = s.width * 0.72;
    final h = s.height * 0.55;
    // Tapa izquierda del libro
    final leftPage = Path()
      ..moveTo(cx - 4, cy - h / 2)
      ..lineTo(cx - w / 2, cy - h / 2 + 10)
      ..lineTo(cx - w / 2, cy + h / 2)
      ..lineTo(cx - 4, cy + h / 2)
      ..close();
    canvas.drawPath(leftPage, _p(0.22, fill: true));
    canvas.drawPath(leftPage, _p(0.40, width: 1.5));
    // Tapa derecha del libro
    final rightPage = Path()
      ..moveTo(cx + 4, cy - h / 2)
      ..lineTo(cx + w / 2, cy - h / 2 + 10)
      ..lineTo(cx + w / 2, cy + h / 2)
      ..lineTo(cx + 4, cy + h / 2)
      ..close();
    canvas.drawPath(rightPage, _p(0.16, fill: true));
    canvas.drawPath(rightPage, _p(0.40, width: 1.5));
    // Lomo del libro
    canvas.drawLine(Offset(cx - 4, cy - h / 2), Offset(cx - 4, cy + h / 2), _p(0.50, width: 3));
    canvas.drawLine(Offset(cx + 4, cy - h / 2), Offset(cx + 4, cy + h / 2), _p(0.50, width: 3));
    // Líneas de texto izquierda
    for (int i = 0; i < 5; i++) {
      final ly = cy - h * 0.28 + i * h * 0.12;
      final lw = i % 3 == 0 ? 0.65 : 0.85;
      canvas.drawLine(Offset(cx - w * 0.44, ly), Offset(cx - w * 0.10 - lw * 10, ly), _p(0.30, width: 1.0));
    }
    // Líneas de texto derecha
    for (int i = 0; i < 5; i++) {
      final ly = cy - h * 0.28 + i * h * 0.12;
      final lw = i % 2 == 0 ? 0.75 : 0.90;
      canvas.drawLine(Offset(cx + w * 0.10, ly), Offset(cx + w * lw * 0.44, ly), _p(0.25, width: 1.0));
    }
  }

  // Las Etapas — timeline grande con nodos y años
  void _etapas(Canvas canvas, Size s) {
    final cy = s.height * 0.50;
    canvas.drawLine(Offset(20, cy), Offset(s.width - 20, cy), _p(0.35, width: 2.5));
    final xs = [0.10, 0.30, 0.50, 0.70, 0.90];
    for (int i = 0; i < xs.length; i++) {
      final c = Offset(s.width * xs[i], cy);
      final r = i == 2 ? 14.0 : 10.0;
      canvas.drawCircle(c, r + 6, _p(0.12, fill: true));
      canvas.drawCircle(c, r, _p(0.38, fill: true));
      canvas.drawCircle(c, r, _p(0.55, width: 1.8));
      final up = i % 2 == 0;
      canvas.drawLine(c, c + Offset(0, up ? -55 : 55), _p(0.28, width: 1.5));
      final lx = c.dx;
      final lineY = c.dy + (up ? -55 : 55);
      canvas.drawLine(Offset(lx - 22, lineY), Offset(lx + 22, lineY), _p(0.25, width: 1.2));
    }
  }

  // Jubilados — dos figuras humanas estilizadas grandes
  void _jubilados(Canvas canvas, Size s) {
    for (int fi = 0; fi < 2; fi++) {
      final cx = s.width * (fi == 0 ? 0.33 : 0.67);
      // Cabeza
      canvas.drawCircle(Offset(cx, s.height * 0.25), 22, _p(0.30, fill: true));
      canvas.drawCircle(Offset(cx, s.height * 0.25), 22, _p(0.50, width: 1.5));
      // Cuerpo
      final body = Path()
        ..moveTo(cx, s.height * 0.47)
        ..lineTo(cx - 26, s.height * 0.72)
        ..lineTo(cx + 26, s.height * 0.72)
        ..close();
      canvas.drawPath(body, _p(0.25, fill: true));
      canvas.drawPath(body, _p(0.45, width: 1.5));
      // Brazos
      canvas.drawLine(Offset(cx - 26, s.height * 0.53), Offset(cx + 26, s.height * 0.53), _p(0.35, width: 2.0));
    }
    // Corazón entre los dos
    _drawHeart(canvas, Offset(s.width * 0.50, s.height * 0.80), 16);
    // Estrella arriba
    _drawStar(canvas, Offset(s.width * 0.50, s.height * 0.10), 14);
  }

  void _drawHeart(Canvas canvas, Offset c, double r) {
    final path = Path()
      ..moveTo(c.dx, c.dy + r * 0.8)
      ..cubicTo(c.dx - r * 1.6, c.dy, c.dx - r * 1.6, c.dy - r, c.dx, c.dy - r * 0.3)
      ..cubicTo(c.dx + r * 1.6, c.dy - r, c.dx + r * 1.6, c.dy, c.dx, c.dy + r * 0.8)
      ..close();
    canvas.drawPath(path, _p(0.38, fill: true));
  }

  void _drawStar(Canvas canvas, Offset center, double r) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final a1 = -math.pi / 2 + i * 2 * math.pi / 5;
      final a2 = a1 + math.pi / 5;
      final outer = center + Offset(math.cos(a1) * r, math.sin(a1) * r);
      final inner = center + Offset(math.cos(a2) * r * 0.42, math.sin(a2) * r * 0.42);
      if (i == 0) {
        path.moveTo(outer.dx, outer.dy);
      } else {
        path.lineTo(outer.dx, outer.dy);
      }
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, _p(0.40, fill: true));
  }

  // Música — pentagrama prominente + notas grandes
  void _musica(Canvas canvas, Size s) {
    final staffTop = s.height * 0.18;
    final staffSpacing = s.height * 0.10;
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(Offset(0, staffTop + i * staffSpacing), Offset(s.width, staffTop + i * staffSpacing), _p(0.38, width: 1.8));
    }
    // Onda de audio en la parte inferior
    final wavePath = Path();
    wavePath.moveTo(0, s.height * 0.82);
    for (double x = 0; x <= s.width; x += 2) {
      wavePath.lineTo(x, s.height * 0.82 + math.sin(x / s.width * 5 * math.pi) * 14);
    }
    canvas.drawPath(wavePath, _p(0.28, width: 2.0));
    // Notas musicales grandes
    _bigNote(canvas, Offset(s.width * 0.18, staffTop + staffSpacing * 1.5), 20);
    _bigNote(canvas, Offset(s.width * 0.55, staffTop + staffSpacing * 0.5), 17);
    _bigNote(canvas, Offset(s.width * 0.82, staffTop + staffSpacing * 2.0), 15);
  }

  void _bigNote(Canvas canvas, Offset pos, double sz) {
    canvas.drawOval(Rect.fromCenter(center: pos, width: sz * 1.4, height: sz), _p(0.45, fill: true));
    canvas.drawLine(Offset(pos.dx + sz * 0.68, pos.dy), Offset(pos.dx + sz * 0.68, pos.dy - sz * 3.0), _p(0.42, width: 2.0));
    // Corchea
    final flagPath = Path()
      ..moveTo(pos.dx + sz * 0.68, pos.dy - sz * 3.0)
      ..quadraticBezierTo(pos.dx + sz * 1.5, pos.dy - sz * 2.4, pos.dx + sz * 0.9, pos.dy - sz * 1.8);
    canvas.drawPath(flagPath, _p(0.42, width: 2.0));
  }

  // Datos Curiosos — bombilla grande con rayos
  void _curiosos(Canvas canvas, Size s) {
    final c = Offset(s.width / 2, s.height * 0.42);
    final r = s.width * 0.22;
    // Cuerpo de la bombilla
    canvas.drawCircle(c, r, _p(0.30, fill: true));
    canvas.drawCircle(c, r, _p(0.50, width: 2.0));
    // Base de la bombilla
    final baseW = r * 0.8;
    canvas.drawLine(Offset(c.dx - baseW, c.dy + r + 8), Offset(c.dx + baseW, c.dy + r + 8), _p(0.45, width: 2.5));
    canvas.drawLine(Offset(c.dx - baseW * 0.8, c.dy + r + 18), Offset(c.dx + baseW * 0.8, c.dy + r + 18), _p(0.45, width: 2.5));
    // Rayos de luz
    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final inner = c + Offset(math.cos(angle) * (r + 10), math.sin(angle) * (r + 10));
      final outer = c + Offset(math.cos(angle) * (r + 30), math.sin(angle) * (r + 30));
      canvas.drawLine(inner, outer, _p(0.32, width: 2.0));
    }
    // Signo de exclamación dentro
    canvas.drawLine(Offset(c.dx, c.dy - r * 0.4), Offset(c.dx, c.dy + r * 0.15), _p(0.55, width: 3.5));
    canvas.drawCircle(Offset(c.dx, c.dy + r * 0.38), 3, _p(0.55, fill: true));
  }

  // Información — reloj (horarios) + ticket (precios) + sobre (contacto)
  void _informacion(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height * 0.40;

    // ── Reloj grande central ─────────────────────────────────────────────
    final r = s.width * 0.26;
    // Aura exterior
    canvas.drawCircle(Offset(cx, cy), r + 14, _p(0.08, fill: true));
    // Cuerpo
    canvas.drawCircle(Offset(cx, cy), r, _p(0.22, fill: true));
    canvas.drawCircle(Offset(cx, cy), r, _p(0.55, width: 2.5));
    // Marcas de hora (12 puntos)
    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6 - math.pi / 2;
      final inner = Offset(cx + math.cos(angle) * (r - 10), cy + math.sin(angle) * (r - 10));
      final outer = Offset(cx + math.cos(angle) * (r - 4),  cy + math.sin(angle) * (r - 4));
      canvas.drawLine(inner, outer, _p(i % 3 == 0 ? 0.55 : 0.30, width: i % 3 == 0 ? 2.0 : 1.2));
    }
    // Manecilla de hora (apunta a las 10)
    final hAngle = -math.pi / 2 + (10 / 12) * 2 * math.pi;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + math.cos(hAngle) * r * 0.52, cy + math.sin(hAngle) * r * 0.52),
      _p(0.65, width: 3.0),
    );
    // Manecilla de minuto (apunta a las 12)
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx, cy - r * 0.70),
      _p(0.65, width: 2.5),
    );
    // Centro del reloj
    canvas.drawCircle(Offset(cx, cy), 5, _p(0.70, fill: true));

    // ── Ticket / entrada — izquierda inferior ─────────────────────────────
    final tx = cx - s.width * 0.26;
    final ty = cy + s.height * 0.28;
    final ticketRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(tx, ty), width: 60, height: 32),
      const Radius.circular(6),
    );
    canvas.drawRRect(ticketRect, _p(0.20, fill: true));
    canvas.drawRRect(ticketRect, _p(0.45, width: 1.5));
    // Borde dentado del ticket
    for (int i = -1; i <= 1; i += 2) {
      canvas.drawCircle(Offset(tx + i * 22.0, ty), 5, _p(0.30, fill: true));
    }
    // Líneas de precio dentro
    canvas.drawLine(Offset(tx - 14, ty - 5), Offset(tx + 14, ty - 5), _p(0.35, width: 1.2));
    canvas.drawLine(Offset(tx - 10, ty + 4), Offset(tx + 10, ty + 4), _p(0.25, width: 1.0));

    // ── Sobre / email — derecha inferior ─────────────────────────────────
    final ex = cx + s.width * 0.26;
    final ey = cy + s.height * 0.28;
    final envRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(ex, ey), width: 58, height: 38),
      const Radius.circular(5),
    );
    canvas.drawRRect(envRect, _p(0.20, fill: true));
    canvas.drawRRect(envRect, _p(0.45, width: 1.5));
    // Flap del sobre (V invertida)
    final flap = Path()
      ..moveTo(ex - 28, ey - 19)
      ..lineTo(ex, ey + 4)
      ..lineTo(ex + 28, ey - 19);
    canvas.drawPath(flap, _p(0.40, width: 1.5));

    // ── Líneas conectoras desde el reloj hacia los íconos ─────────────────
    _drawDottedLine(canvas, Offset(cx - r * 0.55, cy + r * 0.65), Offset(tx + 20, ty - 10), 5);
    _drawDottedLine(canvas, Offset(cx + r * 0.55, cy + r * 0.65), Offset(ex - 20, ey - 10), 5);
  }

  // Cómo Llegar — pin de mapa grande + calles
  void _comoLlegar(Canvas canvas, Size s) {
    // Grilla de calles
    for (int i = 1; i < 5; i++) {
      canvas.drawLine(Offset(0, s.height * i / 5), Offset(s.width, s.height * i / 5), _p(0.12, width: 1.0));
      canvas.drawLine(Offset(s.width * i / 5, 0), Offset(s.width * i / 5, s.height), _p(0.12, width: 1.0));
    }
    final pinX = s.width * 0.50;
    final pinY = s.height * 0.30;
    final pinR = s.width * 0.18;
    // Cuerpo del pin
    final pinPath = Path()
      ..addOval(Rect.fromCenter(center: Offset(pinX, pinY), width: pinR * 2, height: pinR * 2));
    canvas.drawPath(pinPath, _p(0.35, fill: true));
    canvas.drawPath(pinPath, _p(0.55, width: 2.0));
    // Cola del pin
    final tail = Path()
      ..moveTo(pinX - pinR * 0.5, pinY + pinR * 0.7)
      ..lineTo(pinX, pinY + pinR * 2.2)
      ..lineTo(pinX + pinR * 0.5, pinY + pinR * 0.7);
    canvas.drawPath(tail, _p(0.35, fill: true));
    canvas.drawPath(tail, _p(0.55, width: 2.0));
    // Punto interior del pin
    canvas.drawCircle(Offset(pinX, pinY), pinR * 0.38, _p(0.55, fill: true));
    // Ondas de señal alrededor del pin
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(Offset(pinX, pinY), pinR * (1.4 + i * 0.5), _p(0.12 - i * 0.03, width: 1.2));
    }
  }

  // Comunidad — red de personas conectadas
  void _comunidad(Canvas canvas, Size s) {
    final nodes = [
      Offset(s.width * 0.50, s.height * 0.46),
      Offset(s.width * 0.18, s.height * 0.22),
      Offset(s.width * 0.82, s.height * 0.22),
      Offset(s.width * 0.12, s.height * 0.68),
      Offset(s.width * 0.88, s.height * 0.68),
      Offset(s.width * 0.50, s.height * 0.10),
      Offset(s.width * 0.50, s.height * 0.84),
    ];
    final edges = [[0,1],[0,2],[0,3],[0,4],[0,5],[0,6],[1,2],[3,6],[4,6],[1,5],[2,4]];
    for (final e in edges) {
      canvas.drawLine(nodes[e[0]], nodes[e[1]], _p(0.22, width: 1.5));
    }
    for (int i = 0; i < nodes.length; i++) {
      final r = i == 0 ? 18.0 : 13.0;
      canvas.drawCircle(nodes[i], r * 1.5, _p(0.08, fill: true));
      canvas.drawCircle(nodes[i], r, _p(0.32, fill: true));
      canvas.drawCircle(nodes[i], r, _p(0.50, width: 2.0));
      // Cabeza pequeña encima del nodo (figura de persona)
      canvas.drawCircle(nodes[i] - Offset(0, r + 9), r * 0.5, _p(0.28, fill: true));
      canvas.drawCircle(nodes[i] - Offset(0, r + 9), r * 0.5, _p(0.45, width: 1.2));
    }
  }

  // Galerías — marco de foto con cuadrícula y lupa
  void _galeria(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height * 0.45;
    final fw = s.width * 0.62;
    final fh = s.height * 0.50;
    // Marco principal
    final frame = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: fw, height: fh),
      const Radius.circular(12),
    );
    canvas.drawRRect(frame, _p(0.20, fill: true));
    canvas.drawRRect(frame, _p(0.50, width: 2.0));
    // Paisaje interior: cielo
    canvas.drawLine(Offset(cx - fw * 0.42, cy - fh * 0.05),
        Offset(cx + fw * 0.42, cy - fh * 0.05), _p(0.22, width: 1.0));
    // Sol
    canvas.drawCircle(Offset(cx - fw * 0.22, cy - fh * 0.28), 14, _p(0.30, fill: true));
    canvas.drawCircle(Offset(cx - fw * 0.22, cy - fh * 0.28), 14, _p(0.45, width: 1.5));
    // Montañas
    final mtn = Path()
      ..moveTo(cx - fw * 0.42, cy + fh * 0.22)
      ..lineTo(cx - fw * 0.10, cy - fh * 0.28)
      ..lineTo(cx + fw * 0.18, cy + fh * 0.08)
      ..lineTo(cx + fw * 0.42, cy - fh * 0.18)
      ..lineTo(cx + fw * 0.42, cy + fh * 0.22);
    canvas.drawPath(mtn, _p(0.26, fill: true));
    canvas.drawPath(mtn, _p(0.40, width: 1.5));
    // Mini marcos secundarios debajo
    for (int i = 0; i < 3; i++) {
      final mx = cx - fw * 0.30 + i * fw * 0.30;
      final my = cy + fh * 0.50 + 14;
      final mf = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(mx, my), width: fw * 0.22, height: fh * 0.14),
        const Radius.circular(5),
      );
      canvas.drawRRect(mf, _p(0.15, fill: true));
      canvas.drawRRect(mf, _p(0.35, width: 1.2));
    }
    // Lupa — esquina inferior derecha
    final lx = cx + fw * 0.52;
    final ly = cy + fh * 0.38;
    canvas.drawCircle(Offset(lx, ly), 18, _p(0.20, fill: true));
    canvas.drawCircle(Offset(lx, ly), 18, _p(0.45, width: 2.0));
    canvas.drawLine(Offset(lx + 13, ly + 13), Offset(lx + 26, ly + 26), _p(0.45, width: 2.5));
  }

  // Red Social — burbujas de chat, corazón, cámara y personas
  void _socialRed(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height * 0.42;

    // Persona central (cabeza + cuerpo)
    canvas.drawCircle(Offset(cx, cy - 36), 26, _p(0.28, fill: true));
    canvas.drawCircle(Offset(cx, cy - 36), 26, _p(0.55, width: 2.0));
    final body = Path()
      ..moveTo(cx, cy - 8)
      ..quadraticBezierTo(cx - 32, cy + 20, cx - 28, cy + 58)
      ..lineTo(cx + 28, cy + 58)
      ..quadraticBezierTo(cx + 32, cy + 20, cx, cy - 8)
      ..close();
    canvas.drawPath(body, _p(0.22, fill: true));
    canvas.drawPath(body, _p(0.48, width: 1.8));

    // Burbuja de chat — derecha superior
    _drawBubble(canvas, Offset(cx + s.width * 0.28, cy - s.height * 0.22), 38, 22, true);

    // Burbuja de chat — izquierda superior
    _drawBubble(canvas, Offset(cx - s.width * 0.28, cy - s.height * 0.18), 30, 18, false);

    // Cámara — derecha inferior
    final camX = cx + s.width * 0.30;
    final camY = cy + s.height * 0.28;
    final camRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(camX, camY), width: 44, height: 32),
      const Radius.circular(6),
    );
    canvas.drawRRect(camRect, _p(0.20, fill: true));
    canvas.drawRRect(camRect, _p(0.45, width: 1.5));
    canvas.drawCircle(Offset(camX, camY), 10, _p(0.35, fill: true));
    canvas.drawCircle(Offset(camX, camY), 10, _p(0.50, width: 1.2));
    // Visor de cámara
    canvas.drawCircle(Offset(camX - 14, camY - 10), 4, _p(0.40, fill: true));

    // Corazón — izquierda inferior
    _drawHeart(canvas, Offset(cx - s.width * 0.28, cy + s.height * 0.25), 20);

    // Puntos de conexión (líneas punteadas hacia las burbujas)
    _drawDottedLine(canvas, Offset(cx + 28, cy - 10),
        Offset(cx + s.width * 0.20, cy - s.height * 0.18), 6);
    _drawDottedLine(canvas, Offset(cx - 28, cy - 10),
        Offset(cx - s.width * 0.20, cy - s.height * 0.14), 6);

    // Ondas de señal / likes flotantes
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(
        Offset(cx, cy - 36),
        26.0 + i * 18,
        _p(0.06 - i * 0.015, width: 1.0),
      );
    }
  }

  void _drawBubble(Canvas canvas, Offset pos, double w, double h, bool tailRight) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: pos, width: w, height: h),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, _p(0.22, fill: true));
    canvas.drawRRect(rect, _p(0.48, width: 1.5));
    // Cola de la burbuja
    final tailX = tailRight ? pos.dx - w * 0.25 : pos.dx + w * 0.25;
    final tail = Path()
      ..moveTo(tailX - 5, pos.dy + h / 2)
      ..lineTo(tailX, pos.dy + h / 2 + 10)
      ..lineTo(tailX + 5, pos.dy + h / 2)
      ..close();
    canvas.drawPath(tail, _p(0.22, fill: true));
    canvas.drawPath(tail, _p(0.45, width: 1.0));
    // Líneas de texto dentro
    for (int i = 0; i < 2; i++) {
      canvas.drawLine(
        Offset(pos.dx - w * 0.35, pos.dy - 3.0 + i * 8),
        Offset(pos.dx + w * (i == 0 ? 0.35 : 0.20), pos.dy - 3.0 + i * 8),
        _p(0.30, width: 1.0),
      );
    }
  }

  void _drawDottedLine(Canvas canvas, Offset a, Offset b, int dots) {
    for (int i = 1; i < dots; i++) {
      final t = i / dots;
      final pt = Offset(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t);
      canvas.drawCircle(pt, 2, _p(0.20, fill: true));
    }
  }

  @override
  bool shouldRepaint(covariant _SectionArtPainter old) => old.index != index;
}

class _Section {
  final String titulo;
  final String subtitulo;
  final String categoria;
  final IconData icon;
  final Color color;
  final Color colorSecundario;
  final Widget screen;
  final String? imagePath;

  const _Section({
    required this.titulo,
    required this.subtitulo,
    required this.categoria,
    required this.icon,
    required this.color,
    required this.colorSecundario,
    required this.screen,
    this.imagePath,
  });
}

final _sections = [
  _Section(
    titulo: 'Historia',
    subtitulo: 'Conocé los orígenes del museo y su trayectoria cultural',
    categoria: 'PATRIMONIO',
    icon: Icons.history_edu,
    color: const Color(0xFF1B9E8A),
    colorSecundario: const Color(0xFF0D6B5F),
    screen: const IntroHistoriaScreen(),
    imagePath: 'assets/images/historia.jpeg',
  ),
  _Section(
    titulo: 'Las Etapas',
    subtitulo: 'El Origen y la evolución del museo a través del tiempo',
    categoria: 'CRONOLOGÍA',
    icon: Icons.timeline,
    color: const Color(0xFF1A2B4A),
    colorSecundario: const Color(0xFF2E4A7A),
    screen: const EtapasScreen(),
  ),
  _Section(
    titulo: 'Jubilados',
    subtitulo: 'Actividades y beneficios especiales para adultos mayores',
    categoria: 'COMUNIDAD',
    icon: Icons.people,
    color: const Color(0xFF5B6FA0),
    colorSecundario: const Color(0xFF3A4D7A),
    screen: const JubiladosScreen(),
  ),
  _Section(
    titulo: 'Galerías',
    subtitulo: 'Explora nuestro acervo fotográfico e histórico',
    categoria: 'ARCHIVO VISUAL',
    icon: Icons.photo_library,
    color: const Color(0xFF2E7D9A),
    colorSecundario: const Color(0xFF1A5E75),
    screen: const ImagesScreen(),
  ),
  _Section(
    titulo: 'Música',
    subtitulo: 'Conciertos, eventos y patrimonio musical de Mendoza',
    categoria: 'ARTE & CULTURA',
    icon: Icons.music_note,
    color: const Color(0xFF7B5EA7),
    colorSecundario: const Color(0xFF4A3570),
    screen: const MusicaScreen(),
  ),
  _Section(
    titulo: 'Datos Curiosos',
    subtitulo: 'Lo que no sabías sobre nuestro museo',
    categoria: 'DESCUBRIMIENTO',
    icon: Icons.lightbulb,
    color: const Color(0xFFC9961A),
    colorSecundario: const Color(0xFF8A6410),
    screen: const DatosCuriososScreen(),
  ),
  _Section(
    titulo: 'Información',
    subtitulo: 'Horarios de atención, precios y contacto',
    categoria: 'SERVICIOS',
    icon: Icons.info_outline,
    color: const Color(0xFF1B6EA8),
    colorSecundario: const Color(0xFF0D4A7A),
    screen: const InformacionScreen(),
  ),
  _Section(
    titulo: 'Cómo Llegar',
    subtitulo: 'Ubicación, acceso y medios de transporte',
    categoria: 'ACCESO',
    icon: Icons.directions,
    color: const Color(0xFF2E9E5E),
    colorSecundario: const Color(0xFF1A6B3A),
    screen: const ComoLlegarScreen(),
    imagePath: 'assets/images/mapaUM.png',
  ),
  _Section(
    titulo: 'Comunidad',
    subtitulo: 'Explora, conecta y comparte con otros egresados',
    categoria: 'RED SOCIAL',
    icon: Icons.hub_rounded,
    color: const Color(0xFFE04E4E),
    colorSecundario: const Color(0xFF9B1A1A),
    screen: const MuroScreen(),
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  late final StreamSubscription<AuthState> _authStateSubscription;
  int _currentPage = 0;
  bool _isAdmin = false;
  final _adminService = AdminService();

  Future<void> _checkAdminStatus() async {
    final isAdmin = await _adminService.isCurrentUserAdmin();
    if (mounted && _isAdmin != isAdmin) {
      setState(() => _isAdmin = isAdmin);
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _checkAdminStatus();
    
    // Inicializar Push Notifications si el usuario está logueado
    if (Supabase.instance.client.auth.currentUser != null) {
      PushNotificationService().initialize();
    }
    // Escuchar cambios en la sesión para actualizar la UI del Drawer y AppBar
    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        _checkAdminStatus();
        if (data.event == AuthChangeEvent.signedIn) {
          PushNotificationService().initialize();
        }
        setState(() {}); // Forzar reconstrucción de la pantalla
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  static const Color _gold      = Color(0xFFB8973A);
  static const Color _goldLight = Color(0xFFD4AF5A);

  @override
  Widget build(BuildContext context) {
    final current = _sections[_currentPage];
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF080E18),
      // ── AppBar flotante transparente ────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 22, height: 1.5, color: _goldLight),
            const SizedBox(width: 10),
            const Text(
              'MUSEO',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(width: 10),
            Container(width: 22, height: 1.5, color: _goldLight),
          ],
        ),
        centerTitle: true,
        actions: [
          if (Supabase.instance.client.auth.currentUser != null)
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client
                  .from('in_app_notifications')
                  .stream(primaryKey: ['id'])
                  .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
                  .map((list) =>
                      list.where((n) => n['leido'] == false).toList()),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 24),
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                    ),
                    if (count > 0)
                      Positioned(
                        right: 8, top: 10,
                        child: Container(
                          width: 16, height: 16,
                          decoration: BoxDecoration(
                            color: _gold, shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            count > 9 ? '9+' : '$count',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          IconButton(
            icon: Icon(
              Supabase.instance.client.auth.currentUser != null
                  ? Icons.person_rounded
                  : Icons.person_outline_rounded,
              color: Colors.white, size: 24,
            ),
            onPressed: () {
              if (Supabase.instance.client.auth.currentUser != null) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()));
              } else {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.near_me_outlined, color: Colors.white, size: 22),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ComoLlegarScreen())),
          ),
        ],
      ),
      // ── Drawer ──────────────────────────────────────────────────────────
      drawer: Drawer(
        backgroundColor: const Color(0xFF0D1521),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F1C35), Color(0xFF1A3050)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _gold.withValues(alpha: 0.5), width: 1.5),
                    ),
                    child: const Icon(Icons.account_balance_rounded, color: _goldLight, size: 32),
                  ),
                  const SizedBox(height: 16),
                  const Text('MUSEO UM',
                      style: TextStyle(
                        color: Colors.white, fontSize: 22,
                        fontWeight: FontWeight.w900, letterSpacing: 2.5,
                      )),
                  const SizedBox(height: 4),
                  Text('George W. Caviness',
                      style: TextStyle(
                        color: _goldLight.withValues(alpha: 0.8), fontSize: 12,
                      )),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3A2800), Color(0xFFD4AF5A), Color(0xFF3A2800)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: _sections.length,
                itemBuilder: (context, index) {
                  final s = _sections[index];
                  final isActive = index == _currentPage;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: isActive
                          ? s.color.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: isActive
                          ? Border.all(color: s.color.withValues(alpha: 0.35))
                          : null,
                    ),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      leading: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: s.color.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(s.icon, color: s.color, size: 20),
                      ),
                      title: Text(s.titulo,
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.white70,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 14,
                          )),
                      subtitle: Text(s.categoria,
                          style: TextStyle(
                            color: s.color.withValues(alpha: 0.8),
                            fontSize: 10,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w600,
                          )),
                      onTap: () {
                        Navigator.pop(context); // Cerrar el drawer
                        _pageController.jumpToPage(index); // Actualizar el carrusel de fondo
                        
                        // Ir directamente a la pantalla correspondiente
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => s.screen,
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return SlideTransition(
                                position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero)
                                    .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 400),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 1,
              color: Colors.white.withValues(alpha: 0.08),
            ),
            const SizedBox(height: 8),
            if (Supabase.instance.client.auth.currentUser == null)
              _DrawerTile(
                icon: Icons.login_rounded,
                label: 'Iniciar Sesión',
                color: _goldLight,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
              )
            else ...[
              _DrawerTile(
                icon: Icons.person_rounded,
                label: 'Mi Perfil',
                color: Colors.white70,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()));
                },
              ),
              _DrawerTile(
                icon: Icons.group_rounded,
                label: 'Conexiones y Mensajes',
                color: Colors.white70,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SocialHubScreen()));
                },
              ),
              if (_isAdmin)
                _DrawerTile(
                  icon: Icons.admin_panel_settings_rounded,
                  label: 'Panel de Administrador',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
                  },
                ),
              _DrawerTile(
                icon: Icons.logout_rounded,
                label: 'Cerrar Sesión',
                color: Colors.redAccent,
                onTap: () async {
                  Navigator.pop(context);
                  await Supabase.instance.client.auth.signOut();
                },
              ),
            ],
            SizedBox(height: 16 + bottomPad),
          ],
        ),
      ),
      // ── Body: pantalla completa con panel inferior ──────────────────────
      body: Stack(
        children: [
          // Full-screen pager
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _sections.length,
            itemBuilder: (_, index) {
              final s = _sections[index];
              return GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity != null && details.primaryVelocity! < -100) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => s.screen,
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero)
                                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                  // Fondo: imagen real o gradiente + arte
                  if (s.imagePath != null)
                    Image.asset(s.imagePath!, fit: BoxFit.cover)
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [s.colorSecundario, s.color],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: CustomPaint(painter: _SectionArtPainter(index)),
                    ),
                  // Gradiente overlay encima/abajo
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.55),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.92),
                        ],
                        stops: const [0.0, 0.38, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          ),

          // Panel de información inferior
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 28 + bottomPad),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge de categoría
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey(current.categoria),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: current.color.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(current.icon, color: Colors.white, size: 12),
                          const SizedBox(width: 6),
                          Text(
                            current.categoria,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Título grande
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: Text(
                      current.titulo,
                      key: ValueKey(current.titulo),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Separador dorado
                  Row(
                    children: [
                      Container(width: 28, height: 2, color: _gold),
                      Container(
                        width: 5, height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: _gold),
                      ),
                      Expanded(child: Container(height: 1, color: _gold.withValues(alpha: 0.25))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Subtítulo
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      current.subtitulo,
                      key: ValueKey(current.subtitulo),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  // Fila: botón + indicadores
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => current.screen,
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return SlideTransition(
                                position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero)
                                    .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 400),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                          decoration: BoxDecoration(
                            color: current.color,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: current.color.withValues(alpha: 0.5),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Explorar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Indicadores de página
                      Row(
                        children: List.generate(
                          _sections.length,
                          (i) => GestureDetector(
                            onTap: () => _goToPage(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: i == _currentPage ? 18 : 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: i == _currentPage
                                    ? _goldLight
                                    : Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Número de sección — esquina superior derecha
          Positioned(
            top: MediaQuery.of(context).padding.top + 56,
            right: 20,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _currentPage < 9
                    ? '0${_currentPage + 1} / 0${_sections.length}'
                    : '${_currentPage + 1} / ${_sections.length}',
                key: ValueKey(_currentPage),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }
}
