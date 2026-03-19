import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/profanity_filter.dart';
import '../login/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _client = Supabase.instance.client;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _mentoriaAbierta = false;
  
  String _profileTheme = 'ocean'; 
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _puestoController = TextEditingController();
  final TextEditingController _empresaController = TextEditingController();

  final TextEditingController _deleteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _deleteController.dispose();
    _bioController.dispose();
    _estadoController.dispose();
    _puestoController.dispose();
    _empresaController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    try {
      final response = await _client
          .from('profiles')
          .select('mentoria_abierta, profile_theme, biografia, estado_actual, puesto_actual, empresa_actual')
          .eq('id', user.id)
          .single();
      if (mounted) {
        setState(() {
          _mentoriaAbierta = response['mentoria_abierta'] ?? false;
          _profileTheme = response['profile_theme'] ?? 'ocean';
          _bioController.text = response['biografia'] ?? '';
          _estadoController.text = response['estado_actual'] ?? '';
          _puestoController.text = response['puesto_actual'] ?? '';
          _empresaController.text = response['empresa_actual'] ?? '';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfileData() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    
    final newBio = _bioController.text.trim();
    final newEstado = _estadoController.text.trim();
    final newPuesto = _puestoController.text.trim();
    final newEmpresa = _empresaController.text.trim();
    
    if (ProfanityFilter.hasProfanity(newBio) || ProfanityFilter.hasProfanity(newEstado) || 
        ProfanityFilter.hasProfanity(newPuesto) || ProfanityFilter.hasProfanity(newEmpresa)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tus datos contienen lenguaje no permitido.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _client.from('profiles').update({
        'biografia': newBio,
        'estado_actual': newEstado,
        'puesto_actual': newPuesto,
        'empresa_actual': newEmpresa,
        'profile_theme': _profileTheme
      }).eq('id', user.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil guardado exitosamente.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
      await _client.from('profiles').update({'mentoria_abierta': value}).eq('id', user.id);
    } catch (e) {
      if (mounted) {
        setState(() => _mentoriaAbierta = !value); // Revert
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir $urlString'), backgroundColor: Colors.red),
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
          title: const Text('Eliminar Cuenta', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️ Esta acción es IRREVERSIBLE. Se borrarán todos tus posts, mensajes y datos del museo de manera permanente.'),
              const SizedBox(height: 16),
              const Text('Para confirmar, escribe "ELIMINAR" abajo:'),
              const SizedBox(height: 8),
              TextField(
                controller: _deleteController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                onChanged: (val) => setState(() {}), // Trigger rebuild to enable button
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _deleteController,
              builder: (context, value, child) {
                final isEnabled = value.text == 'ELIMINAR';
                return TextButton(
                  onPressed: isEnabled ? () => Navigator.pop(context, true) : null,
                  child: Text('Confirmar Eliminación', style: TextStyle(color: isEnabled ? Colors.red : Colors.grey)),
                );
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        // En un entorno de Supabase real, la eliminación autogestionada del user_id de auth.users requiere permisos.
        // Simularemos o llamaremos al backend si está configurado. Como es el prompt, usamos un delete de profiles.
        // Un ON DELETE CASCADE en auth.users no es posible por el cliente, pero borrar profiles borrará sus datos de app.
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
            SnackBar(content: Text('Error al eliminar cuenta: $e'), backgroundColor: Colors.red),
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
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1B9E8A),
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
        title: const Text('Configuración', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A2B4A))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A2B4A)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildSectionHeader('Editar Perfil'),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _profileTheme,
                        decoration: InputDecoration(
                           labelText: 'Tema Visual del Perfil',
                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                           DropdownMenuItem(value: 'ocean', child: Text('Océano Profundo (Azules)')),
                           DropdownMenuItem(value: 'forest', child: Text('Bosque Nativo (Verdes)')),
                           DropdownMenuItem(value: 'sunset', child: Text('Ocaso del Museo (Naranjas)')),
                           DropdownMenuItem(value: 'dark', child: Text('Noche (Grises)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _profileTheme = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _estadoController,
                        maxLength: 100,
                        decoration: InputDecoration(
                          labelText: 'Estado Actual / Frase',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _puestoController,
                        decoration: InputDecoration(
                          labelText: 'Puesto o Cargo Actual',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _empresaController,
                        decoration: InputDecoration(
                          labelText: 'Empresa',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _bioController,
                        maxLength: 150,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Acerca de Mí',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfileData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B9E8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          child: _isSaving 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Guardar Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ]
                  ),
                ),

                _buildSectionHeader('Preferencias'),
                SwitchListTile(
                  secondary: const Icon(Icons.school, color: Color(0xFF1A2B4A)),
                  title: const Text('Abierto a dar Mentoría', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: _mentoriaAbierta,
                  activeColor: const Color(0xFF1B9E8A),
                  onChanged: _toggleMentoria,
                ),
                
                _buildSectionHeader('Privacidad y Seguridad'),
                ListTile(
                  leading: const Icon(Icons.lock, color: Color(0xFF1A2B4A)),
                  title: const Text('Privacidad del Perfil', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Placeholder
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode, color: Color(0xFF1A2B4A)),
                  title: const Text('Tema de la Aplicación', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Placeholder
                  },
                ),

                _buildSectionHeader('Legal'),
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: Color(0xFF1A2B4A)),
                  title: const Text('Política de Privacidad', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () => _launchUrl('https://um.edu.mx/privacidad'),
                ),
                ListTile(
                  leading: const Icon(Icons.description, color: Color(0xFF1A2B4A)),
                  title: const Text('Términos de Servicio', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () => _launchUrl('https://um.edu.mx/terminos'),
                ),
                ListTile(
                  leading: const Icon(Icons.email, color: Color(0xFF1A2B4A)),
                  title: const Text('Contactar al Soporte', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () => _launchUrl('mailto:soporte@um.edu.mx?subject=Soporte%20App%20Museo'),
                ),

                _buildSectionHeader('Zona de Peligro'),
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.orange),
                  title: const Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  onTap: _signOut,
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Eliminar cuenta', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  onTap: _deleteAccount,
                ),
                const SizedBox(height: 40),
              ],
            ),
    );
  }
}
