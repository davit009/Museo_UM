import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Registrar nuevo usuario con metadatos de perfil
  Future<AuthResponse> registerUsuario({
    required String email,
    required String password,
    required String nombre,
    required DateTime fechaNacimiento,
    required String matricula,
    required String carrera,
    required String generacion,
    required bool esEgresado,
    String? puestoActual,
    String? empresaActual,
    bool mentoriaAbierta = false,
  }) async {
    // 1. Crear el usuario en Auth
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'nombre': nombre,
        'matricula': matricula,
        'carrera': carrera,
      },
    );

    final user = response.user;
    if (user != null) {
      // 2. Guardar o actualizar datos adicionales en la tabla 'profiles'
      final mapData = {
        'id': user.id, // Debe coincidir con el ID de auth.users
        'nombre': nombre,
        'fecha_nacimiento': fechaNacimiento.toIso8601String().split('T')[0], // YYYY-MM-DD
        'matricula': matricula,
        'carrera': carrera,
        'generacion': generacion,
        'es_egresado': esEgresado,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (esEgresado) {
        mapData['puesto_actual'] = puestoActual ?? '';
        mapData['empresa_actual'] = empresaActual ?? '';
        mapData['mentoria_abierta'] = mentoriaAbierta;
      }

      await _client.from('profiles').upsert(mapData);
    }

    return response;
  }

  // Registrar nuevo usuario (Simple, mantenido por compatibilidad)
  Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Iniciar sesión (Modificado para soportar Matrícula o Correo)
  Future<AuthResponse> signIn(String identificador, String password) async {
    String email = identificador.trim();

    // Si el identificador no tiene '@', asumimos que es una matrícula
    if (!email.contains('@')) {
      try {
        final response = await _client.rpc('get_email_por_matricula', params: {
          'p_matricula': email
        });
        
        if (response != null && response.toString().isNotEmpty) {
          email = response.toString();
        } else {
          throw Exception('No existe una cuenta con esa matrícula.');
        }
      } catch (e) {
        if (e.toString().contains('No existe')) rethrow;
        throw Exception('Error al verificar la matrícula. Asegúrate de haber ejecutado el script SQL en Supabase.');
      }
    }

    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Obtener el usuario actual
  User? get currentUser => _client.auth.currentUser;
}