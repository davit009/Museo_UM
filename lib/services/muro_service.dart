import 'package:supabase_flutter/supabase_flutter.dart';

class MuroService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Trae todos los posts con el username del perfil, ordenados del más nuevo al más viejo.
  Future<List<Map<String, dynamic>>> fetchPosts() async {
    final response = await _client
        .from('posts')
        .select('*, profiles(username)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Crea un nuevo post. El user_id se obtiene del usuario autenticado.
  Future<void> createPost(String contenido) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Debés iniciar sesión para publicar.');
    await _client.from('posts').insert({
      'user_id': userId,
      'contenido': contenido,
    });
  }

  /// Elimina un post propio.
  Future<void> deletePost(int postId) async {
    await _client.from('posts').delete().eq('id', postId);
  }

  /// Devuelve el usuario actual autenticado (null si no hay sesión).
  User? get currentUser => _client.auth.currentUser;
}
