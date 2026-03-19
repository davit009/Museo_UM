import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/profanity_filter.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentProfileData;
  final bool esEgresado;

  const EditProfileScreen({
    super.key,
    required this.currentProfileData,
    required this.esEgresado,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _client = Supabase.instance.client;
  bool _isSaving = false;
  
  late String _profileTheme;
  late TextEditingController _bioController;
  late TextEditingController _estadoController;
  late TextEditingController _puestoController;
  late TextEditingController _empresaController;

  @override
  void initState() {
    super.initState();
    _profileTheme = widget.currentProfileData['profile_theme'] ?? 'ocean';
    _bioController = TextEditingController(text: widget.currentProfileData['biografia'] ?? '');
    _estadoController = TextEditingController(text: widget.currentProfileData['estado_actual'] ?? '');
    _puestoController = TextEditingController(text: widget.currentProfileData['puesto_actual'] ?? '');
    _empresaController = TextEditingController(text: widget.currentProfileData['empresa_actual'] ?? '');
  }

  @override
  void dispose() {
    _bioController.dispose();
    _estadoController.dispose();
    _puestoController.dispose();
    _empresaController.dispose();
    super.dispose();
  }

  Future<void> _saveProfileData() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    
    final newBio = _bioController.text.trim();
    final newEstado = _estadoController.text.trim();
    // Solo guardamos puesto y empresa si es egresado
    final newPuesto = widget.esEgresado ? _puestoController.text.trim() : null;
    final newEmpresa = widget.esEgresado ? _empresaController.text.trim() : null;
    
    if (ProfanityFilter.hasProfanity(newBio) || ProfanityFilter.hasProfanity(newEstado) || 
        (newPuesto != null && ProfanityFilter.hasProfanity(newPuesto)) || 
        (newEmpresa != null && ProfanityFilter.hasProfanity(newEmpresa))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tus datos contienen lenguaje no permitido.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updateData = {
        'biografia': newBio,
        'estado_actual': newEstado,
        'profile_theme': _profileTheme
      };
      
      if (widget.esEgresado) {
        updateData['puesto_actual'] = newPuesto!;
        updateData['empresa_actual'] = newEmpresa!;
      }

      await _client.from('profiles').update(updateData).eq('id', user.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil guardado exitosamente.'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Retornamos true indicando que hubo cambios
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A2B4A))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A2B4A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personaliza tu espacio',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A2B4A)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aquí puedes ajustar cómo te ven los demás en el Museo UM.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),

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
            const SizedBox(height: 20),
            
            TextField(
              controller: _estadoController,
              maxLength: 100,
              decoration: InputDecoration(
                labelText: 'Estado Actual / Frase Corta',
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
                alignLabelWithHint: true,
              ),
            ),

            if (widget.esEgresado) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              const Text(
                'Experiencia Profesional',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B9E8A)),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _puestoController,
                decoration: InputDecoration(
                  labelText: 'Puesto o Cargo Actual',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _empresaController,
                decoration: InputDecoration(
                  labelText: 'Empresa',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],

            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfileData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B9E8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: _isSaving 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Guardar Cambios', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
