import 'package:supabase_flutter/supabase_flutter.dart';

class AdminService {
  final SupabaseClient _client = Supabase.instance.client;

  // 1. Obtener Lista de todos los posts
  Future<List<Map<String, dynamic>>> fetchAllPosts() async {
    final response = await _client
        .from('posts')
        .select('*, profiles(username, nombre, avatar_url)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // 2. Eliminar Post
  Future<void> deletePost(int postId) async {
    // Si la regla RLS del backend está bien configurada, esto funcionará para el admin
    await _client.from('posts').delete().eq('id', postId);
  }

  // 2.5 Obtener Reportes
  Future<List<Map<String, dynamic>>> fetchReports() async {
    final response = await _client
        .from('reports')
        .select('*, profiles!reporter_id(nombre, username), posts(id, contenido, user_id, profiles!user_id(nombre, username))')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> dismissReport(String reportId) async {
    await _client.from('reports').delete().eq('id', reportId);
  }

  // 3. Obtener Lista de todos los perfiles
  Future<List<Map<String, dynamic>>> fetchAllProfiles() async {
    final response = await _client
        .from('profiles')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // 4. Eliminar Perfil  (Baneo Fuerte)
  Future<void> deleteProfile(String profileId) async {
    // Esto disparará ON DELETE CASCADE para los posts, connections y blocks ligados al perfil
    await _client.from('profiles').delete().eq('id', profileId);
  }

  // 5. Obtener el rol del usuario actual
  Future<String> getCurrentUserRole() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return 'user';

    Map<String, dynamic>? response;
    try {
      response = await _client
          .from('profiles')
          .select('role, is_admin')
          .eq('id', uid)
          .maybeSingle();
    } catch (_) {
      response = await _client
          .from('profiles')
          .select('role')
          .eq('id', uid)
          .maybeSingle();
    }

    if (response == null) return 'user';

    final roleValue = (response['role'] ?? '').toString().trim().toLowerCase();
    final isAdminFlag = response['is_admin'] == true;

    if (isAdminFlag || roleValue == 'superadmin' || roleValue == 'admin') {
      return 'superadmin';
    } else if (roleValue == 'editor' || roleValue == 'moderator') {
      return 'editor';
    }

    return 'user';
  }

  // Helper para verificar si es cualquier tipo de admin
  Future<bool> isCurrentUserAdmin() async {
    final role = await getCurrentUserRole();
    return role == 'superadmin' || role == 'editor';
  }

  // Helper para verificar si es Super Admin (puede borrar posts, banear, etc)
  Future<bool> isCurrentUserSuperAdmin() async {
    final role = await getCurrentUserRole();
    return role == 'superadmin';
  }

  // 6. Actualizar rol de usuario
  Future<void> updateUserRole(String userId, String newRole) async {
    await _client.from('profiles').update({'role': newRole}).eq('id', userId);
  }
}
