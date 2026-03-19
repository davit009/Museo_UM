import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/profanity_filter.dart';
import 'social_service.dart';

class MuroService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchPosts() async {
    final response = await _client
        .from('posts')
        .select('*, profiles(username, nombre, carrera, generacion, avatar_url, biografia, linkedin_url, email_publico, mentoria_abierta), post_reactions(user_id, reaction_type)')
        .order('created_at', ascending: false);
    
    final posts = List<Map<String, dynamic>>.from(response);
    final blockedUsers = await SocialService().getBlockedUsers();
    
    return posts.where((p) => !blockedUsers.contains(p['user_id'].toString())).toList();
  }

  /// Crea un nuevo post.
  Future<void> createPost(String contenido) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Debés iniciar sesión para publicar.');
    
    if (ProfanityFilter.hasProfanity(contenido)) {
      throw Exception('El mensaje contiene lenguaje no permitido para el contexto universitario.');
    }

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

  /// Fetch Perfil of Current User (useful for filtering)
  Future<Map<String, dynamic>?> getMyProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return null;
    return await _client.from('profiles').select().eq('id', userId).maybeSingle();
  }

  /// Reaccionar a un post (agrega, cambia o elimina la reaccion)
  Future<void> toggleReaction(int postId, String reactionType) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('Debés iniciar sesión para reaccionar.');

    // 1. Verificar si ya tiene una reaccion en este post
    final existing = await _client
        .from('post_reactions')
        .select()
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      if (existing['reaction_type'] == reactionType) {
        // Si clicó la misma reaccion, la quitamos
        await _client.from('post_reactions').delete().eq('id', existing['id']);
      } else {
        // Cambiar por nueva reaccion
        await _client.from('post_reactions').update({'reaction_type': reactionType}).eq('id', existing['id']);
      }
    } else {
      // No existe, insertar
      await _client.from('post_reactions').insert({
        'post_id': postId,
        'user_id': userId,
        'reaction_type': reactionType,
      });
    }
  }
}
