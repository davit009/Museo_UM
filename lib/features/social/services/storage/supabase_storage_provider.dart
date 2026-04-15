import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:museo_app/features/social/services/storage/storage_provider.dart';

/// Implementación de almacenamiento que utiliza Supabase Storage.
class SupabaseStorageProvider implements StorageProvider {
  final SupabaseClient _client = Supabase.instance.client;
  final String _bucketName = 'muro_images';

  @override
  Future<String> uploadImage(File file, String path) async {
    // Sube el archivo al bucket
    await _client.storage.from(_bucketName).upload(path, file);
    
    // Obtiene y retorna la URL pública
    return _client.storage.from(_bucketName).getPublicUrl(path);
  }
}
