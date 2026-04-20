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
      case 0: { _historia(canvas, size); break; }
      case 1: { _etapas(canvas, size);   break; }
      case 2: { _jubilados(canvas, size); break; }
      case 3: { _musica(canvas, size);   break; }
      case 4: { _curiosos(canvas, size); break; }
      case 5: { _informacion(canvas, size); break; }
      case 6: { _comoLlegar(canvas, size);  break; }
      case 7: { _comunidad(canvas, size);   break; }
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

  // Información — fachada de museo con columnas prominentes
  void _informacion(Canvas canvas, Size s) {
    final baseY = s.height * 0.85;
    final leftX  = s.width * 0.08;
    final rightX = s.width * 0.92;
    // Frontón (triángulo)
    final pediment = Path()
      ..moveTo(leftX, s.height * 0.48)
      ..lineTo(s.width / 2, s.height * 0.16)
      ..lineTo(rightX, s.height * 0.48)
      ..close();
    canvas.drawPath(pediment, _p(0.22, fill: true));
    canvas.drawPath(pediment, _p(0.45, width: 2.0));
    // Entablamiento horizontal
    canvas.drawLine(Offset(leftX, s.height * 0.48), Offset(rightX, s.height * 0.48), _p(0.45, width: 2.5));
    canvas.drawLine(Offset(leftX, s.height * 0.53), Offset(rightX, s.height * 0.53), _p(0.30, width: 1.5));
    // Base
    canvas.drawLine(Offset(leftX * 0.7, baseY), Offset(rightX * 1.03, baseY), _p(0.45, width: 3.0));
    canvas.drawLine(Offset(leftX * 0.5, baseY + 8), Offset(rightX * 1.05, baseY + 8), _p(0.30, width: 2.0));
    // Columnas
    for (int i = 0; i < 6; i++) {
      final x = leftX + (rightX - leftX) * i / 5;
      final colPath = Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 7, s.height * 0.53, 14, baseY - s.height * 0.53),
          const Radius.circular(3)));
      canvas.drawPath(colPath, _p(0.22, fill: true));
      canvas.drawPath(colPath, _p(0.42, width: 1.2));
    }
    // Puerta
    final doorPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(s.width / 2, baseY - 20), width: 28, height: 38),
        const Radius.circular(4)));
    canvas.drawPath(doorPath, _p(0.35, fill: true));
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
    icon: Icons.forum,
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
    _pageController = PageController(viewportFraction: 0.82);
    
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

  @override
  Widget build(BuildContext context) {
    final current = _sections[_currentPage];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF1A2B4A), size: 26),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          }
        ),
        title: const Text(
          'MUSEO',
          style: TextStyle(
            color: Color(0xFF1A2B4A),
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
        actions: [
          // Notification Bell
          if (Supabase.instance.client.auth.currentUser != null)
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client
                  .from('in_app_notifications')
                  .stream(primaryKey: ['id'])
                  .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
                  .map((list) => list.where((notif) => notif['leido'] == false).toList()),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data?.length ?? 0;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1A2B4A), size: 26),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                        );
                      },
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                  ],
                );
              },
            ),

          // Perfil / Login dinámico según sesión
          IconButton(
            icon: Icon(
              Supabase.instance.client.auth.currentUser != null 
                ? Icons.person_pin 
                : Icons.account_circle_outlined, 
              color: const Color(0xFF1A2B4A)
            ),
            onPressed: () {
              if (Supabase.instance.client.auth.currentUser != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              }
            },
          ),
          
          // Icono del Mapa
          IconButton(
            icon: const Icon(Icons.map_outlined, color: Color(0xFF1A2B4A), size: 26),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ComoLlegarScreen()),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF1A2B4A),
              ),
              child: const SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.account_balance, color: Colors.white, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'MUSEO UM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _sections.length,
                itemBuilder: (context, index) {
                  final section = _sections[index];
                  return ListTile(
                    leading: Icon(section.icon, color: section.color),
                    title: Text(
                      section.titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A2B4A),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Cerrar el drawer
                      // Actualizar el carrusel de fondo silenciosamente
                      _pageController.jumpToPage(index);
                      
                      // Ir directamente a la pantalla correspondiente
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => section.screen,
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
                  );
                },
              ),
            ),
            const Divider(),
            if (Supabase.instance.client.auth.currentUser == null)
              ListTile(
                leading: const Icon(Icons.login, color: Color(0xFF1A2B4A)),
                title: const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2B4A),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.person, color: Color(0xFF1A2B4A)),
                title: const Text(
                  'Mi Perfil',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2B4A),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.group, color: Color(0xFF1A2B4A)),
                title: const Text(
                  'Conexiones y Mensajes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2B4A),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SocialHubScreen()),
                  );
                },
              ),
              if (_isAdmin)
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings, color: Colors.orange),
                  title: const Text(
                    'Panel de Administrador',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await Supabase.instance.client.auth.signOut();
                  // No se necesita hacer más, onAuthStateChange redibujará la pantalla
                },
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tabs horizontales ──
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _sections.length,
              itemBuilder: (context, index) {
                final selected = index == _currentPage;
                final section = _sections[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8, top: 2, bottom: 2),
                  child: GestureDetector(
                    onTap: () => _goToPage(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? section.color : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? section.color : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        section.titulo,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.grey.shade500,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Watermark EXPLORA ──
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 8),
            child: Text(
              'EXPLORA',
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
                color: current.color.withValues(alpha: 0.10),
              ),
            ),
          ),

          // ── Carrusel ──
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _sections.length,
              itemBuilder: (context, index) {
                final section = _sections[index];
                final isActive = index == _currentPage;

                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isActive ? 1.0 : 0.45,
                  child: AnimatedScale(
                  scale: isActive ? 1.0 : 0.86,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => section.screen,
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
                    onVerticalDragEnd: (details) {
                      // Detect swipe up
                      if (details.primaryVelocity != null && details.primaryVelocity! < -100) {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => section.screen,
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
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: section.color.withValues(alpha: 0.30),
                                  blurRadius: 36,
                                  offset: const Offset(0, 18),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.07),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Column(
                          children: [
                            // ── Zona superior: foto o gradiente con ilustración ──
                            Expanded(
                              flex: 12,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: section.imagePath != null
                                      ? Colors.black
                                      : null,
                                  gradient: section.imagePath == null
                                      ? LinearGradient(
                                          colors: [section.color, section.colorSecundario],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                ),
                                child: Stack(
                                  children: [
                                    // Foto real si existe, si no ilustración
                                    if (section.imagePath != null)
                                      Positioned.fill(
                                        child: Image.asset(
                                          section.imagePath!,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    // Ilustración para secciones sin foto
                                    if (section.imagePath == null)
                                      Positioned.fill(
                                        child: CustomPaint(
                                          painter: _SectionArtPainter(index),
                                        ),
                                      ),
                                    // Número de catálogo — esquina superior izquierda
                                    Positioned(
                                      top: 18,
                                      left: 20,
                                      child: Text(
                                        index < 9 ? '— 0${index + 1}' : '— ${index + 1}',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.75),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 2.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // ── Zona inferior: etiqueta editorial sobre fondo blanco ──
                            Expanded(
                              flex: 8,
                              child: Container(
                                width: double.infinity,
                                color: Colors.white,
                                padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Categoría con guión de color
                                    Row(
                                      children: [
                                        Container(
                                          width: 18,
                                          height: 2,
                                          decoration: BoxDecoration(
                                            color: section.color,
                                            borderRadius: BorderRadius.circular(1),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          section.categoria,
                                          style: TextStyle(
                                            color: section.color,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    // Título
                                    Text(
                                      section.titulo,
                                      style: const TextStyle(
                                        color: Color(0xFF0F1C33),
                                        fontSize: 23,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.3,
                                        height: 1.05,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    // Divisor fino
                                    Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: Colors.grey.shade100,
                                    ),
                                    const SizedBox(height: 5),
                                    // Subtítulo
                                    Text(
                                      section.subtitulo,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 11.5,
                                        height: 1.4,
                                      ),
                                    ),
                                    const Spacer(),
                                    // Fila inferior: "Ver colección" + flecha
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Ver colección',
                                          style: TextStyle(
                                            color: section.color,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: section.color,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ),
                );
              },
            ),
          ),

          // ── Indicadores de página ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _sections.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
                width: i == _currentPage ? 22 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _currentPage
                      ? _sections[_currentPage].color
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
