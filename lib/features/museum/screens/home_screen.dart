import 'package:flutter/material.dart';
import 'package:museo_app/features/museum/screens/intro_historia_screen.dart';
import 'package:museo_app/features/museum/screens/etapas_screen.dart';
import 'package:museo_app/features/museum/screens/jubilados_screen.dart';
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

class _Section {
  final String titulo;
  final String subtitulo;
  final IconData icon;
  final Color color;
  final Color colorSecundario;
  final Widget screen;

  const _Section({
    required this.titulo,
    required this.subtitulo,
    required this.icon,
    required this.color,
    required this.colorSecundario,
    required this.screen,
  });
}

final _sections = [
  _Section(
    titulo: 'Historia',
    subtitulo: 'Conocé los orígenes del museo y su trayectoria cultural',
    icon: Icons.history_edu,
    color: const Color(0xFF1B9E8A),
    colorSecundario: const Color(0xFF0D6B5F),
    screen: const IntroHistoriaScreen(),
  ),
  _Section(
    titulo: 'Las Etapas',
    subtitulo: 'El Origen y la evolución del museo a través del tiempo',
    icon: Icons.timeline,
    color: const Color(0xFF1A2B4A),
    colorSecundario: const Color(0xFF2E4A7A),
    screen: const EtapasScreen(),
  ),
  _Section(
    titulo: 'Jubilados',
    subtitulo: 'Actividades y beneficios especiales para adultos mayores',
    icon: Icons.people,
    color: const Color(0xFF5B6FA0),
    colorSecundario: const Color(0xFF3A4D7A),
    screen: const JubiladosScreen(),
  ),
  _Section(
    titulo: 'Música',
    subtitulo: 'Conciertos, eventos y patrimonio musical de Montemorelos',
    icon: Icons.music_note,
    color: const Color(0xFF7B5EA7),
    colorSecundario: const Color(0xFF4A3570),
    screen: const MusicaScreen(),
  ),
  _Section(
    titulo: 'Datos Curiosos',
    subtitulo: 'Lo que no sabías sobre nuestro museo',
    icon: Icons.lightbulb,
    color: const Color(0xFFC9961A),
    colorSecundario: const Color(0xFF8A6410),
    screen: const DatosCuriososScreen(),
  ),
  _Section(
    titulo: 'Información',
    subtitulo: 'Horarios de atención, precios y contacto',
    icon: Icons.info_outline,
    color: const Color(0xFF1B6EA8),
    colorSecundario: const Color(0xFF0D4A7A),
    screen: const InformacionScreen(),
  ),
  _Section(
    titulo: 'Cómo Llegar',
    subtitulo: 'Ubicación, acceso y medios de transporte',
    icon: Icons.directions,
    color: const Color(0xFF2E9E5E),
    colorSecundario: const Color(0xFF1A6B3A),
    screen: const ComoLlegarScreen(),
  ),
  _Section(
    titulo: 'Comunidad',
    subtitulo: 'Explora, conecta y comparte con otros egresados',
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
                      'Museo UM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Montemorelos, N.L., México',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
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
                      _goToPage(index); // Navegar a la página correspondiente en el carrusel
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

                return AnimatedScale(
                  scale: isActive ? 1.0 : 0.92,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => section.screen),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [section.color, section.colorSecundario],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: section.color.withValues(alpha: 0.40),
                                  blurRadius: 28,
                                  offset: const Offset(0, 14),
                                ),
                              ]
                            : [],
                      ),
                      child: Stack(
                        children: [
                          // Icono de fondo decorativo
                          Positioned(
                            right: -20,
                            bottom: -20,
                            child: Icon(
                              section.icon,
                              size: 180,
                              color: Colors.white.withValues(alpha: 0.07),
                            ),
                          ),
                          // Contenido
                          Padding(
                            padding: const EdgeInsets.all(36),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Icon(section.icon, color: Colors.white, size: 48),
                                ),
                                const SizedBox(height: 28),
                                Text(
                                  section.titulo,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  section.subtitulo,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Text(
                                      'Ver más',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white.withValues(alpha: 0.85),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
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

          // ── Botón explorar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => current.screen),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: current.color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(current.icon, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      current.titulo.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
