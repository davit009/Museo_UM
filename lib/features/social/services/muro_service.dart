import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:museo_app/core/utils/profanity_filter.dart';
import 'package:museo_app/features/social/services/social_service.dart';
import 'package:museo_app/features/social/services/storage/storage_provider.dart';
import 'package:museo_app/features/social/services/storage/supabase_storage_provider.dart';

class MuroService {
  final SupabaseClient _client = Supabase.instance.client;
  final StorageProvider _storageProvider = SupabaseStorageProvider();

  Future<List<Map<String, dynamic>>> fetchPosts() async {
    final response = await _client
        .from('posts')
        .select('*, profiles(username, nombre, carrera, generacion, avatar_url, biografia, linkedin_url, email_publico, mentoria_abierta, es_egresado, role, is_admin), post_reactions(user_id, reaction_type), post_comments(id), post_mentions(user_id, profiles(nombre, username))')
        .order('created_at', ascending: false);
    
    final posts = List<Map<String, dynamic>>.from(response);
    final blockedUsers = await SocialService().getBlockedUsers();
    
    return posts.where((p) => !blockedUsers.contains(p['user_id'].toString())).toList();
  }

  /// Crea un nuevo post con categoría, etiquetas e imágenes opcionales.
  Future<void> createPost(String contenido, {String categoria = 'General', List<String> taggedUserIds = const [], List<File> imageFiles = const []}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Debés iniciar sesión para publicar.');
    
    if (ProfanityFilter.hasProfanity(contenido)) {
      throw Exception('El mensaje contiene lenguaje no permitido para el contexto universitario.');
    }

    // Subir imágenes si existen
    List<String> imageUrls = [];
    if (imageFiles.isNotEmpty) {
      for (var i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        final ext = file.path.split('.').last;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final path = '$userId/${timestamp}_img_$i.$ext';
        
        try {
          final url = await _storageProvider.uploadImage(file, path);
          imageUrls.add(url);
        } catch (e) {
          throw Exception('Error al subir la imagen: $e');
        }
      }
    }

    final postResponse = await _client.from('posts').insert({
      'user_id': userId,
      'contenido': contenido,
      'categoria': categoria,
      if (imageUrls.isNotEmpty) 'image_urls': imageUrls,
    }).select('id').single();

    final postId = postResponse['id'];

    if (taggedUserIds.isNotEmpty) {
      final mentions = taggedUserIds.map((tid) => {
        'post_id': postId,
        'user_id': tid,
      }).toList();
      
      await _client.from('post_mentions').insert(mentions);
    }
  }

  /// Cargar comentarios de un post
  Future<List<Map<String, dynamic>>> fetchComments(int postId) async {
    final response = await _client
        .from('post_comments')
        .select('*, profiles(nombre, username, carrera, es_egresado)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Agregar un comentario a un post
  Future<void> addComment(int postId, String contenido) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Debés iniciar sesión para comentar.');
    
    if (ProfanityFilter.hasProfanity(contenido)) {
      throw Exception('El comentario contiene lenguaje no permitido.');
    }

    await _client.from('post_comments').insert({
      'post_id': postId,
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
