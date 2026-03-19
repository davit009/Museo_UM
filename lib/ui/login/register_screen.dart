import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  
  // Controladores
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _matriculaController = TextEditingController();
  final _otraCarreraController = TextEditingController();
  final _generacionInicioController = TextEditingController();
  final _generacionFinController = TextEditingController();
  
  DateTime? _fechaNacimiento;
  bool _isLoading = false;

  final List<String> _carreras = [
    'Licenciatura en Arquitectura',
    'Licenciatura en Artes Visuales',
    'Licenciatura en Comunicación y Medios',
    'Licenciatura en Diseño de Comunicación Visual',
    'Maestría en Dirección de Comunicación',
    'Licenciatura en Cirujano Dentista',
    'Licenciatura en Enfermería',
    'Licenciatura en Médico Cirujano',
    'Licenciatura en Nutrición',
    'Licenciatura en Químico Clínico Biólogo',
    'Licenciatura en Terapia Física y Rehabilitación',
    'Técnico en Tecnología Dental',
    'Especialidad en Odontología',
    'Especialidad en Oftalmología',
    'Maestría en Salud Pública',
    'Licenciaturas del Área Educativa',
    'Posgrados en Educación',
    'Licenciatura en Administración y Negocios Internacionales',
    'Licenciatura en Contaduría Pública',
    'Licenciatura en Derecho',
    'Posgrados en Administración',
    'Ingeniería en Electrónica y Telecomunicaciones',
    'Ingeniería en Gestión de Tecnologías de la Información',
    'Ingeniería en Sistemas Computacionales',
    'Ingeniería Industrial y de Sistemas',
    'Maestría en Redes y Seguridad',
    'Licenciatura en Música',
    'Escuela Preparatoria',
    'Licenciaturas en Psicología',
    'Posgrados en Psicología',
    'Licenciatura en Teología',
    'Otro'
  ];
  String? _selectedCarrera;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    _matriculaController.dispose();
    _otraCarreraController.dispose();
    _generacionInicioController.dispose();
    _generacionFinController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(2000),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A148C),
              onPrimary: Colors.white,
              onSurface: Color(0xFF4A148C),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _fechaNacimiento) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona tu fecha de nacimiento')),
      );
      return;
    }
    if (_selectedCarrera == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una carrera')),
      );
      return;
    }

    final carreraFinal = _selectedCarrera == 'Otro' 
        ? _otraCarreraController.text.trim() 
        : _selectedCarrera!;

    if (_selectedCarrera == 'Otro' && carreraFinal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor especifica tu carrera')),
      );
      return;
    }

    if (_generacionInicioController.text.trim().isEmpty || _generacionFinController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa ambos años de tu generación')),
      );
      return;
    }

    final generacionFinal = '${_generacionInicioController.text.trim()}-${_generacionFinController.text.trim()}';

    setState(() => _isLoading = true);

    try {
      await _authService.registerUsuario(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        nombre: _nombreController.text.trim(),
        fechaNacimiento: _fechaNacimiento!,
        matricula: _matriculaController.text.trim(),
        carrera: carreraFinal,
        generacion: generacionFinal,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Registro exitoso! Iniciando sesión...'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Vuelve a la pantalla de login (o navega al home)
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF4A148C)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4A148C), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Crear Cuenta',
          style: TextStyle(color: Color(0xFF4A148C), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4A148C)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Únete al Museo UM',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4A148C),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Completa tus datos para registrarte',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),

                // Datos de la cuenta
                const Text('Datos de Cuenta', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _emailController,
                  label: 'Correo Electrónico',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Datos Personales
                const Text('Información Personal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _nombreController,
                  label: 'Nombre Completo',
                  icon: Icons.person_outline,
                ),

                // Selector de Fecha
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade50,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xFF4A148C)),
                          const SizedBox(width: 12),
                          Text(
                            _fechaNacimiento == null
                                ? 'Fecha de Nacimiento'
                                : DateFormat('dd/MM/yyyy').format(_fechaNacimiento!),
                            style: TextStyle(
                              fontSize: 16,
                              color: _fechaNacimiento == null ? Colors.grey.shade600 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Datos Universitarios
                const Text('Datos Universitarios', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _matriculaController,
                  label: 'Matrícula / ID',
                  icon: Icons.badge_outlined,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCarrera,
                    decoration: InputDecoration(
                      labelText: 'Carrera',
                      prefixIcon: const Icon(Icons.school_outlined, color: Color(0xFF4A148C)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4A148C), width: 2)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    isExpanded: true,
                    items: _carreras.map((String carrera) {
                      return DropdownMenuItem<String>(
                        value: carrera,
                        child: Text(carrera, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCarrera = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Por favor selecciona una carrera' : null,
                  ),
                ),
                if (_selectedCarrera == 'Otro')
                  _buildTextField(
                    controller: _otraCarreraController,
                    label: 'Especifica tu carrera',
                    icon: Icons.edit_outlined,
                  ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _generacionInicioController,
                        label: 'Año Inicio',
                        icon: Icons.history_edu,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('-', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    Expanded(
                      child: _buildTextField(
                        controller: _generacionFinController,
                        label: 'Año Fin',
                        icon: Icons.history_edu,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: Color(0xFF4A148C)))
                else
                  ElevatedButton(
                    onPressed: _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A148C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'CREAR CUENTA',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
