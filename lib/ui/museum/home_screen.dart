import 'package:flutter/material.dart';
import 'intro_historia_screen.dart';
import 'etapas_screen.dart';
import 'jubilados_screen.dart';
import 'musica_screen.dart';
import 'datos_curiosos_screen.dart';
import 'informacion_screen.dart';
import 'como_llegar_screen.dart';
import '../login/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    subtitulo: 'Conciertos, eventos y patrimonio musical de Mendoza',
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
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82);
  }

  @override
  void dispose() {
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
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF1A2B4A), size: 26),
          onPressed: () {},
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
  // --- TU NUEVO BOTÓN DE LOGIN ---
  IconButton(
    icon: const Icon(Icons.account_circle_outlined, color: Color(0xFF1A2B4A), size: 26),
    onPressed: () {
      // Navega a tu pantalla de Login
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    },

  ),

  // En actions:
IconButton(
  icon: Icon(
    // Si hay usuario en Supabase, muestra el check, si no, el círculo
    Supabase.instance.client.auth.currentUser != null 
      ? Icons.person_pin 
      : Icons.account_circle_outlined, 
    color: Color(0xFF1A2B4A)
  ),
  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
),
  // --- BOTÓN DEL MAPA (YA EXISTÍA) ---
  IconButton(
    icon: const Icon(Icons.map_outlined, color: Color(0xFF1A2B4A), size: 26),
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ComoLlegarScreen()),
    ),
  ),
],
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
