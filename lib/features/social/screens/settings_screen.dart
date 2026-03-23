import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:museo_app/features/auth/screens/login_screen.dart';
import 'package:museo_app/features/social/screens/edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _client = Supabase.instance.client;
  bool _isLoading = true;
  bool _mentoriaAbierta = false;
  Map<String, dynamic>? _profileData;
  bool _esEgresado = false;

  final TextEditingController _deleteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _deleteController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final response = await _client
          .from('profiles')
          .select(
            'mentoria_abierta, profile_theme, biografia, estado_actual, puesto_actual, empresa_actual, es_egresado',
          )
          .eq('id', user.id)
          .single();

      if (mounted) {
        setState(() {
          _profileData = response;
          _mentoriaAbierta = response['mentoria_abierta'] ?? false;
          _esEgresado = response['es_egresado'] ?? false;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleMentoria(bool value) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    setState(() => _mentoriaAbierta = value); // Optimistic Update

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Actualizando...'),
          duration: Duration(milliseconds: 1500),
          backgroundColor: Color(0xFF1B9E8A),
        ),
      );
    }

    try {
      await _client
          .from('profiles')
          .update({'mentoria_abierta': value})
          .eq('id', user.id);
    } catch (e) {
      if (mounted) {
        setState(() => _mentoriaAbierta = !value); // Revert
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir $urlString'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    await _client.auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _deleteAccount() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Eliminar Cuenta',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '⚠️ Esta acción es IRREVERSIBLE. Se borrarán todos tus posts, mensajes y datos del museo de manera permanente.',
              ),
              const SizedBox(height: 16),
              const Text('Para confirmar, escribe "ELIMINAR" abajo:'),
              const SizedBox(height: 8),
              TextField(
                controller: _deleteController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                onChanged: (val) => setState(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _deleteController,
              builder: (context, value, child) {
                final isEnabled = value.text == 'ELIMINAR';
                return TextButton(
                  onPressed: isEnabled
                      ? () => Navigator.pop(context, true)
                      : null,
                  child: Text(
                    'Confirmar Eliminación',
                    style: TextStyle(
                      color: isEnabled ? Colors.red : Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _client.from('profiles').delete().eq('id', user.id);
        await _client.auth.signOut();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar cuenta: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1B9E8A),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Configuración',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2B4A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A2B4A)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A2B4A)),
            )
          : ListView(
              children: [
                _buildSectionHeader('Cuenta'),
                Container(
                  color: Colors.white,
                  child: ListTile(
                    leading: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF1A2B4A),
                    ),
                    title: const Text(
                      'Editar Información del Perfil',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Actualiza tu biografía, estado y rol',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      if (_profileData == null) return;
                      final bool? changed = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(
                            currentProfileData: _profileData!,
                            esEgresado: _esEgresado,
                          ),
                        ),
                      );
                      if (changed == true && mounted) {
                        _loadPreferences(); // Recargar datos si hubo cambios
                      }
                    },
                  ),
                ),

                if (_esEgresado) ...[
                  _buildSectionHeader('Networking (Solo Egresados)'),
                  Container(
                    color: Colors.white,
                    child: SwitchListTile(
                      secondary: const Icon(
                        Icons.school,
                        color: Color(0xFF1A2B4A),
                      ),
                      title: const Text(
                        'Abierto a dar Mentoría',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Permite que estudiantes te contacten',
                      ),
                      value: _mentoriaAbierta,
                      activeThumbColor: const Color(0xFF1B9E8A),
                      onChanged: _toggleMentoria,
                    ),
                  ),
                ] else ...[
                  _buildSectionHeader('Networking'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Al terminar tu carrera podrás ofrecer mentorías a otros alumnos.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],

                _buildSectionHeader('Privacidad y Seguridad'),
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF1A2B4A),
                        ),
                        title: const Text(
                          'Privacidad de la Cuenta',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.notifications_outlined,
                          color: Color(0xFF1A2B4A),
                        ),
                        title: const Text(
                          'Notificaciones',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                _buildSectionHeader('Legal y Soporte'),
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.privacy_tip_outlined,
                          color: Color(0xFF1A2B4A),
                        ),
                        title: const Text(
                          'Política de Privacidad',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onTap: () => _launchUrl('https://um.edu.mx/privacidad'),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.description_outlined,
                          color: Color(0xFF1A2B4A),
                        ),
                        title: const Text(
                          'Términos de Servicio',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onTap: () => _launchUrl('https://um.edu.mx/terminos'),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.support_agent,
                          color: Color(0xFF1A2B4A),
                        ),
                        title: const Text(
                          'Contactar al Soporte',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onTap: () => _launchUrl(
                          'mailto:soporte@um.edu.mx?subject=Soporte%20App%20Museo',
                        ),
                      ),
                    ],
                  ),
                ),

                _buildSectionHeader('Zona de Peligro'),
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.exit_to_app,
                          color: Colors.orange,
                        ),
                        title: const Text(
                          'Cerrar Sesión',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                        onTap: _signOut,
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        ),
                        title: const Text(
                          'Eliminar cuenta',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        onTap: _deleteAccount,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
    );
  }
}
