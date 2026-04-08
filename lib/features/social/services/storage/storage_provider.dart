import 'dart:io';

/// Abstracción para el almacenamiento de archivos.
/// Cuando se desee migrar a un nuevo servidor (SSH, S3, etc.),
/// simplemente se debe crear una nueva clase que implemente esta interfaz.
abstract class StorageProvider {
  /// Sube una imagen y retorna su URL pública o accesible.
  /// [file]: El archivo a subir.
  /// [path]: El path o nombre deseado del archivo.
  Future<String> uploadImage(File file, String path);
}
