import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:museo_app/features/social/screens/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _client = Supabase.instance.client;
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  String _profileTheme = 'ocean'; // Default Theme

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      if (mounted) {
        setState(() {
          _profileData = response;
          _profileTheme = _profileData!['profile_theme'] ?? 'ocean';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar perfil: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  LinearGradient _getGradientTheme(String themeName) {
    switch (themeName) {
      case 'forest':
        return const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)]);
      case 'sunset':
        return const LinearGradient(colors: [Color(0xFFE64A19), Color(0xFFD84315)]);
      case 'dark':
        return const LinearGradient(colors: [Color(0xFF37474F), Color(0xFF263238)]);
      case 'ocean':
      default:
        return const LinearGradient(colors: [Color(0xFF1A2B4A), Color(0xFF0D1B2A)]);
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'No especificada';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd \'de\' MMMM, yyyy', 'es_MX').format(date);
    } catch (_) {
      return dateString;
    }
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2B4A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1A2B4A), size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'No especificado' : value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1A2B4A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1A2B4A)),
        ),
      );
    }

    if (_profileData == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Mi Perfil'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: Text('No se pudo cargar la información del perfil.'),
        ),
      );
    }

    final nombre = _profileData!['nombre'] ?? 'Usuario';
    final email = _client.auth.currentUser?.email ?? 'Sin correo';
    final matricula = _profileData!['matricula'] ?? '';
    final carrera = _profileData!['carrera'] ?? '';
    final generacion = _profileData!['generacion'] ?? '';
    final fechaNacimiento = _profileData!['fecha_nacimiento'];
    
    final estadoActual = _profileData!['estado_actual'] as String?;
    final puestoActual = _profileData!['puesto_actual'] as String?;
    final empresaActual = _profileData!['empresa_actual'] as String?;
    final biografia = _profileData!['biografia'] as String?;
    final esEgresado = _profileData!['es_egresado'] ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A2B4A)),
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: Color(0xFF1A2B4A),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
             icon: const Icon(Icons.settings),
             onPressed: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (_) => const SettingsScreen()),
               ).then((_) {
                  // Refresh profile on return
                  if (mounted) _loadProfile();
               });
             },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              decoration: BoxDecoration(
                gradient: _getGradientTheme(_profileTheme),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: const Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),

                  if (estadoActual != null && estadoActual.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16)
                      ),
                      child: Text('"$estadoActual"', style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),
                    ),

                  if ((puestoActual != null && puestoActual.isNotEmpty) || (empresaActual != null && empresaActual.isNotEmpty))
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.work_outline, color: Colors.white70, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            (puestoActual?.isNotEmpty == true ? puestoActual! : 'Profesional') +
                            (empresaActual?.isNotEmpty == true ? ' en $empresaActual' : ''),
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      )
                    ),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      esEgresado ? 'Ex Alumno' : 'Alumno Activo',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Body Info
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (biografia != null && biografia.isNotEmpty) ...[
                    const Text(
                      'Acerca de mí',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B9E8A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      biografia,
                      style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                  ],

                  const Text(
                    'Información Universitaria',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B9E8A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProfileItem(Icons.badge, 'Matrícula', matricula),
                  _buildProfileItem(Icons.school, 'Carrera', carrera),
                  _buildProfileItem(Icons.history_edu, 'Generación', generacion),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'Información Personal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B9E8A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProfileItem(Icons.cake, 'Fecha de Nacimiento', _formatDate(fechaNacimiento)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
