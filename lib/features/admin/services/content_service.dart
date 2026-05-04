import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Maneja lectura y escritura de bloques de texto editables
/// guardados en la tabla `museum_config` de Supabase.
///
/// Estructura en BD:
///   key   TEXT PRIMARY KEY   → p.ej. "informacion.horarios"
///   value JSONB              → el contenido (string, lista, mapa)
class ContentService {
  final SupabaseClient _client = Supabase.instance.client;

  // ── Cargar todos los bloques de una sección ─────────────────────────────
  Future<Map<String, dynamic>> loadSection(String section) async {
    try {
      final rows = await _client
          .from('museum_config')
          .select('key, value')
          .like('key', '$section.%');

      final Map<String, dynamic> result = {};
      for (final row in rows) {
        final key = (row['key'] as String).replaceFirst('$section.', '');
        result[key] = row['value'];
      }
      return result;
    } catch (e) {
      debugPrint('ContentService.loadSection error: $e');
      return {};
    }
  }

  // ── Guardar un bloque individual ────────────────────────────────────────
  Future<void> saveBlock(String section, String key, dynamic value) async {
    await _client.from('museum_config').upsert(
      {
        'key': '$section.$key',
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'key',
    );
  }

  // ── Guardar múltiples bloques de una sección ────────────────────────────
  Future<void> saveSection(String section, Map<String, dynamic> data) async {
    final rows = data.entries.map((e) => {
      'key': '$section.${e.key}',
      'value': e.value,
      'updated_at': DateTime.now().toIso8601String(),
    }).toList();

    await _client.from('museum_config').upsert(rows, onConflict: 'key');
  }

  // ── Helper: obtener string con fallback ─────────────────────────────────
  static String str(Map<String, dynamic> data, String key, String fallback) {
    final v = data[key];
    if (v == null) return fallback;
    return v.toString();
  }

  // ── Helper: obtener lista de strings con fallback ───────────────────────
  static List<String> strList(Map<String, dynamic> data, String key, List<String> fallback) {
    final v = data[key];
    if (v == null || v is! List) return fallback;
    return v.map((e) => e.toString()).toList();
  }

  // ── Helper: obtener lista de mapas con fallback ─────────────────────────
  static List<Map<String, dynamic>> mapList(
      Map<String, dynamic> data, String key, List<Map<String, dynamic>> fallback) {
    final v = data[key];
    if (v == null || v is! List) return fallback;
    return v.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
