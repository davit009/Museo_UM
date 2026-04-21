import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:museo_app/features/admin/services/admin_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const List<String> _galleryBaseUrls = [
  'http://64.23.168.72/media',
  'http://64.23.168.72',
  'http://64.23.168.72/media/Galeria',
  'http://64.23.168.72/Galeria',
  'http://64.23.168.72/media/Galerias',
  'http://64.23.168.72/Galerias',
];

const List<String> _galleryApiBaseUrls = [
  'http://64.23.168.72/api/gallery',
  'https://64.23.168.72/api/gallery',
];

Map<String, String> _serverAuthHeaders() {
  final accessToken = Supabase.instance.client.auth.currentSession?.accessToken;
  if (accessToken == null || accessToken.isEmpty) return {};
  return {'Authorization': 'Bearer $accessToken'};
}

class ImagesScreen extends StatefulWidget {
  const ImagesScreen({super.key});

  @override
  State<ImagesScreen> createState() => _ImagesScreenState();
}

class _ImagesScreenState extends State<ImagesScreen> {
  final AdminService _adminService = AdminService();
  final List<Map<String, dynamic>> _collections = List<Map<String, dynamic>>.from(
    _defaultImageFolders,
  );

  bool _isAdmin = false;
  bool _isBusy = false;

  static const Color _navy      = Color(0xFF0F1C35);
  static const Color _gold      = Color(0xFFB8973A);
  static const Color _goldLight = Color(0xFFD4AF5A);
  static const Color _cream     = Color(0xFFF5F0E8);
  static const List<Color> _dynamicFolderColors = [
    Color(0xFF8B4513),
    Color(0xFF1B5E75),
    Color(0xFF2D5016),
    Color(0xFFC32F27),
    Color(0xFF7B5EA7),
    Color(0xFF1A2B4A),
    Color(0xFF2E7D9A),
    Color(0xFF5B6FA0),
    Color(0xFF1B9E8A),
    Color(0xFFC9961A),
    Color(0xFF5A3A5A),
    Color(0xFF2C5282),
  ];

  Color _colorForFolder(String folderPath) {
    final key = folderPath.trim().toLowerCase();
    if (key.isEmpty) return const Color(0xFF44617B);

    final index = key.hashCode.abs() % _dynamicFolderColors.length;
    return _dynamicFolderColors[index];
  }

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _loadServerCollections();
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await _adminService.isCurrentUserAdmin();
    if (!mounted) return;
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  Future<void> _loadServerCollections() async {
    final seen = <String>{
      for (final item in _collections) item['path'] as String,
    };
    final discovered = <Map<String, dynamic>>[];

    final fromApi = await _loadServerCollectionsFromApi();
    for (final folder in fromApi) {
      final folderPath = (folder['path'] ?? '').toString();
      if (folderPath.isEmpty || seen.contains(folderPath)) continue;
      seen.add(folderPath);
      discovered.add(folder);
    }

    for (final baseUrl in _galleryBaseUrls) {
      try {
        final html = await NetworkAssetBundle(Uri.parse('$baseUrl/')).loadString('');
        if (!html.contains('Index of')) continue;

        final hrefRegex = RegExp(r'href="([^"]+)"', caseSensitive: false);
        for (final match in hrefRegex.allMatches(html)) {
          final href = match.group(1);
          if (href == null || href.isEmpty || href == '../' || href.startsWith('?')) {
            continue;
          }
          if (!href.endsWith('/')) continue;

          final folder = Uri.decodeComponent(href.substring(0, href.length - 1));
          if (folder.trim().isEmpty || seen.contains(folder)) continue;

          seen.add(folder);
          discovered.add(
            {
              'title': folder,
              'path': folder,
              'icon': Icons.folder,
              'color': _colorForFolder(folder),
            },
          );
        }
      } catch (_) {
        // Sigue con la siguiente base.
      }
    }

    if (!mounted || discovered.isEmpty) return;
    setState(() {
      _collections.addAll(discovered);
    });
  }

  Future<List<Map<String, dynamic>>> _loadServerCollectionsFromApi() async {
    final headers = {
      ..._serverAuthHeaders(),
      'Content-Type': 'application/json',
    };

    for (final apiBase in _galleryApiBaseUrls) {
      final cleanBase = apiBase.endsWith('/')
          ? apiBase.substring(0, apiBase.length - 1)
          : apiBase;
      final uri = Uri.parse('$cleanBase/folders/list');

      try {
        var response = await http.post(
          uri,
          headers: headers,
          body: jsonEncode({'path': ''}),
        );

        if (response.statusCode < 200 || response.statusCode >= 300) {
          final getUri = Uri.parse('$cleanBase/folders/list?path=');
          response = await http.get(getUri, headers: _serverAuthHeaders());
        }

        if (response.statusCode < 200 || response.statusCode >= 300) continue;

        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) continue;
        final foldersRaw = decoded['folders'];
        if (foldersRaw is! List) continue;

        final folders = foldersRaw
            .whereType<String>()
            .where((folder) => folder.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        if (folders.isEmpty) continue;

        return folders
            .map(
              (folder) => {
                'title': folder,
                'path': folder,
                'icon': Icons.folder,
                'color': _colorForFolder(folder),
              },
            )
            .toList();
      } catch (_) {
        // Intentar con siguiente API base.
      }
    }

    return const [];
  }

  Future<String?> _promptText({
    required String title,
    required String hint,
    String? initialValue,
    String confirmLabel = 'Guardar',
  }) async {
    final controller = TextEditingController(text: initialValue ?? '');
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return value?.trim();
  }

  String _safeObjectName(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'\\+'), '-')
        .replaceAll(RegExp(r'/+'), '-')
        .replaceAll(RegExp(r'\s+'), '_');
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  Future<bool> _tryWebDavMethod({
    required String method,
    required String fromPath,
    String? destinationPath,
  }) async {
    final headers = _serverAuthHeaders();

    for (final base in _galleryBaseUrls) {
      final cleanBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
      final encodedFrom = fromPath
          .split('/')
          .where((part) => part.trim().isNotEmpty)
          .map(Uri.encodeComponent)
          .join('/');
      final fromUri = Uri.parse('$cleanBase/$encodedFrom');
      final request = http.Request(method, fromUri);
      request.headers.addAll(headers);

      if (method == 'MOVE' && destinationPath != null) {
        final encodedTo = destinationPath
            .split('/')
            .where((part) => part.trim().isNotEmpty)
            .map(Uri.encodeComponent)
            .join('/');
        final destinationUri = Uri.parse('$cleanBase/$encodedTo');
        request.headers['Destination'] = destinationUri.toString();
        request.headers['Overwrite'] = 'T';
      }

      try {
        final streamed = await request.send();
        if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
          return true;
        }
      } catch (_) {
        // Prueba siguiente base.
      }
    }

    return false;
  }

  Future<bool> _tryApiJsonAction({
    required String endpoint,
    required Map<String, dynamic> payload,
  }) async {
    final headers = {
      ..._serverAuthHeaders(),
      'Content-Type': 'application/json',
    };

    for (final baseUrl in _galleryApiBaseUrls) {
      final cleanBase = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;
      final uri = Uri.parse('$cleanBase/$endpoint');
      try {
        final response = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(payload),
        );
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return true;
        }
      } catch (_) {
        // Prueba el siguiente endpoint base.
      }
    }

    return false;
  }

  Future<void> _createCollection() async {
    if (!_isAdmin || _isBusy) return;

    final name = await _promptText(
      title: 'Crear carpeta',
      hint: 'Nombre de la carpeta',
      confirmLabel: 'Crear',
    );
    if (name == null || name.isEmpty) return;

    final path = _safeObjectName(name);
    if (path.isEmpty) return;

    setState(() => _isBusy = true);
    final ok =
      await _tryApiJsonAction(endpoint: 'folders/create', payload: {'path': path}) ||
      await _tryWebDavMethod(method: 'MKCOL', fromPath: '$path/');
    if (!mounted) return;

    setState(() {
      _isBusy = false;
      if (ok) {
        _collections.add(
          {
            'title': name,
            'path': path,
            'icon': Icons.folder,
            'color': _colorForFolder(path),
          },
        );
      }
    });

    _showMessage(
      ok
          ? 'Carpeta creada correctamente.'
          : 'No se pudo crear la carpeta en el servidor.',
      isError: !ok,
    );
  }

  Future<void> _renameCollection(Map<String, dynamic> folder) async {
    if (!_isAdmin || _isBusy) return;

    final currentPath = folder['path'] as String;
    final requested = await _promptText(
      title: 'Renombrar carpeta',
      hint: 'Nuevo nombre',
      initialValue: currentPath,
      confirmLabel: 'Renombrar',
    );
    if (requested == null || requested.isEmpty) return;

    final newPath = _safeObjectName(requested);
    if (newPath.isEmpty || newPath == currentPath) return;

    setState(() => _isBusy = true);
    final ok =
        await _tryApiJsonAction(
          endpoint: 'folders/rename',
          payload: {'from': currentPath, 'to': newPath},
        ) ||
        await _tryWebDavMethod(
          method: 'MOVE',
          fromPath: currentPath,
          destinationPath: '$newPath/',
        );
    if (!mounted) return;

    setState(() {
      _isBusy = false;
      if (ok) {
        folder['title'] = requested;
        folder['path'] = newPath;
      }
    });

    _showMessage(
      ok
          ? 'Carpeta renombrada correctamente.'
          : 'No se pudo renombrar la carpeta en el servidor.',
      isError: !ok,
    );
  }

  Future<void> _deleteCollection(Map<String, dynamic> folder) async {
    if (!_isAdmin || _isBusy) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar carpeta'),
        content: const Text('Esta acción eliminará la carpeta del servidor. ¿Continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final path = folder['path'] as String;
    setState(() => _isBusy = true);
    final ok =
      await _tryApiJsonAction(endpoint: 'folders/delete', payload: {'path': path}) ||
      await _tryWebDavMethod(method: 'DELETE', fromPath: '$path/');
    if (!mounted) return;

    setState(() {
      _isBusy = false;
      if (ok) {
        _collections.remove(folder);
      }
    });

    _showMessage(
      ok
          ? 'Carpeta eliminada correctamente.'
          : 'No se pudo eliminar la carpeta en el servidor.',
      isError: !ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _navy,
        title: const Text(
          'GALERÍAS',
          style: TextStyle(letterSpacing: 2.5, fontSize: 15, fontWeight: FontWeight.w700),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B5000), Color(0xFFD4AF5A), Color(0xFF6B5000)],
              ),
            ),
          ),
        ),
        actions: [
          if (_isAdmin)
            PopupMenuButton<String>(
              enabled: !_isBusy,
              icon: const Icon(Icons.admin_panel_settings_rounded),
              tooltip: 'CRUD de carpetas',
              onSelected: (value) {
                if (value == 'create') {
                  _createCollection();
                } else if (value == 'refresh') {
                  _loadServerCollections();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem<String>(
                  value: 'create',
                  child: ListTile(
                    leading: Icon(Icons.create_new_folder_rounded),
                    title: Text('Crear carpeta'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'refresh',
                  child: ListTile(
                    leading: Icon(Icons.refresh_rounded),
                    title: Text('Recargar carpetas'),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero banner ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F1C35), Color(0xFF1B3A5C), Color(0xFF0F1C35)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -50, right: -50,
                        child: Container(
                          width: 180, height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _gold.withValues(alpha: 0.06),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 54, height: 54,
                                  decoration: BoxDecoration(
                                    color: _gold.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: _gold.withValues(alpha: 0.45), width: 1.5),
                                  ),
                                  child: const Icon(Icons.photo_library_rounded, color: _goldLight, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'ARCHIVO VISUAL',
                                      style: TextStyle(
                                        color: _goldLight,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Galerías Históricas',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Container(width: 32, height: 1.5, color: _gold),
                                Container(
                                  width: 5, height: 5,
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: _gold),
                                ),
                                Expanded(child: Container(height: 1, color: _gold.withValues(alpha: 0.28))),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Explora el archivo visual del museo con colecciones organizadas por época, institución y memoria histórica.',
                              style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.65),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8, runSpacing: 8,
                              children: [
                                _GoldChip(icon: Icons.collections_rounded, label: '${_collections.length} colecciones'),
                                const _GoldChip(icon: Icons.timeline_rounded, label: 'Archivo histórico'),
                                const _GoldChip(icon: Icons.camera_alt_rounded, label: 'Fotografía'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ── Etiqueta sección ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 4, height: 20,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4AF5A), Color(0xFFB8973A)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'COLECCIONES',
                        style: TextStyle(
                          color: Color(0xFF0F1C35),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ── Lista de colecciones ─────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final folder = _collections[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _FolderCard(
                          title: folder['title'] as String,
                          subtitle: (folder['subtitle'] as String?) ?? 'Colección histórica',
                          icon: folder['icon'] as IconData,
                          color: folder['color'] as Color,
                          folderPath: folder['path'] as String,
                          index: index,
                          isAdmin: _isAdmin,
                          isBusy: _isBusy,
                          onRename: () => _renameCollection(folder),
                          onDelete: () => _deleteCollection(folder),
                        ),
                      );
                    },
                    childCount: _collections.length,
                  ),
                ),
              ),
            ],
          ),
          if (_isBusy)
            Container(
              color: Colors.black.withValues(alpha: 0.18),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

final List<Map<String, dynamic>> _defaultImageFolders = [
  {
    'title': '1894 Iglesia',
    'path': '1894-iglesia-Educación',
    'icon': Icons.church,
    'color': Color(0xFF8B4513),
  },
  {
    'title': '1921 Instituto',
    'path': '1921-42-Instituto Comercial Prosperidad',
    'icon': Icons.school,
    'color': Color(0xFF1B5E75),
  },
  {
    'title': '1942 Escuela Agrícola',
    'path': '1942-51-Escuela Agricola Industrial Mexicana',
    'icon': Icons.agriculture,
    'color': Color(0xFF2D5016),
  },
  {
    'title': '1946 Hospital',
    'path': '1946-Hospital',
    'icon': Icons.local_hospital,
    'color': Color(0xFFC32F27),
  },
  {
    'title': '1951 COVOPROM',
    'path': '1951-72-Covoprom',
    'icon': Icons.business,
    'color': Color(0xFF7B5EA7),
  },
  {
    'title': '1972 Universidad',
    'path': '1972-Universidad',
    'icon': Icons.library_books,
    'color': Color(0xFF1A2B4A),
  },
  {
    'title': '1973 Universidad',
    'path': '1973-Universidad',
    'icon': Icons.account_balance,
    'color': Color(0xFF2E7D9A),
  },
  {
    'title': '2014 UM Vídeo',
    'path': '2014_UM_Video',
    'icon': Icons.videocam,
    'color': Color(0xFF5B6FA0),
  },
  {
    'title': '2018 Actividades',
    'path': '2018-04-11',
    'icon': Icons.event,
    'color': Color(0xFF1B9E8A),
  },
  {
    'title': 'Directores Institución',
    'path': 'Directores-Institución',
    'icon': Icons.person_pin,
    'color': Color(0xFFC9961A),
  },
  {
    'title': 'Directores',
    'path': 'Directores',
    'icon': Icons.people,
    'color': Color(0xFF5A3A5A),
  },
  {
    'title': 'Logos Institución',
    'path': 'Logos Institución',
    'icon': Icons.image_search,
    'color': Color(0xFF2C5282),
  },
];

class _FolderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String folderPath;
  final int index;
  final bool isAdmin;
  final bool isBusy;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  const _FolderCard({
    required this.title,
    this.subtitle = 'Colección histórica',
    required this.icon,
    required this.color,
    required this.folderPath,
    this.index = 0,
    this.isAdmin = false,
    this.isBusy = false,
    this.onRename,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _FolderGalleryScreen(
                folderTitle: title,
                folderPath: folderPath,
                color: color,
              ),
            ),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.98),
                  color.withValues(alpha: 0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.16),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -20,
                  right: -10,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                if (isAdmin)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: PopupMenuButton<String>(
                        enabled: !isBusy,
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (value) {
                          if (value == 'rename') {
                            onRename?.call();
                          } else if (value == 'delete') {
                            onDelete?.call();
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem<String>(
                            value: 'rename',
                            child: ListTile(
                              leading: Icon(Icons.drive_file_rename_outline_rounded),
                              title: Text('Renombrar carpeta'),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete_rounded, color: Colors.red),
                              title: Text('Eliminar carpeta'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 14,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FolderGalleryScreen extends StatefulWidget {
  final String folderTitle;
  final String folderPath;
  final Color color;

  const _FolderGalleryScreen({
    required this.folderTitle,
    required this.folderPath,
    required this.color,
  });

  @override
  State<_FolderGalleryScreen> createState() => _FolderGalleryScreenState();
}

class _FolderGalleryScreenState extends State<_FolderGalleryScreen> {
  static const List<String> _bucketCandidates = [
    'galeria',
    'galeria_images',
    'gallery',
    'images',
    'museo_images',
    'muro_images',
  ];

  final AdminService _adminService = AdminService();
  final ImagePicker _imagePicker = ImagePicker();
  final List<_GalleryImageItem> _images = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  bool _isProcessing = false;
  String? _loadError;
  int _imageVersion = 0;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _loadImages();
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await _adminService.isCurrentUserAdmin();
    if (!mounted) return;
    final shouldReload = !_isAdmin && isAdmin;
    setState(() {
      _isAdmin = isAdmin;
    });
    if (shouldReload) {
      await _loadImages();
    }
  }

  Future<void> _loadImages() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
      _imageVersion = DateTime.now().millisecondsSinceEpoch;
      _images.clear();
    });

    try {
      final fromApi = await _loadImagesFromApi();
      if (fromApi.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _images.addAll(fromApi);
          _isLoading = false;
        });
        return;
      }

      final fromHttpGallery = await _loadImagesFromHttpGallery();
      if (fromHttpGallery.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _images.addAll(fromHttpGallery);
          _isLoading = false;
        });
        return;
      }

      final fromAssets = await _loadImagesFromAssets();
      if (fromAssets.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _images.addAll(fromAssets);
          _isLoading = false;
        });
        return;
      }

      final fromSupabase = await _loadImagesFromSupabase();
      if (!mounted) return;

      setState(() {
        if (fromSupabase != null) _images.addAll(fromSupabase.images);
        _isLoading = false;
      });
    } catch (e, stack) {
      if (!mounted) return;
      debugPrint('Error en _loadImages: $e\\n$stack');
      setState(() {
        _isLoading = false;
        _loadError =
            'Error interno: $e\\nRevisa conexión y permisos de Storage.';
      });
    }
  }

  Future<List<_GalleryImageItem>> _loadImagesFromApi() async {
    final headers = {
      ..._serverAuthHeaders(),
      'Content-Type': 'application/json',
    };

    for (final apiBase in _galleryApiBaseUrls) {
      final cleanBase = apiBase.endsWith('/')
          ? apiBase.substring(0, apiBase.length - 1)
          : apiBase;
      final uri = Uri.parse('$cleanBase/files/list');

      try {
        var response = await http.post(
          uri,
          headers: headers,
          body: jsonEncode({'path': widget.folderPath}),
        );

        if (response.statusCode < 200 || response.statusCode >= 300) {
          final encodedPath = Uri.encodeQueryComponent(widget.folderPath);
          final getUri = Uri.parse('$cleanBase/files/list?path=$encodedPath');
          response = await http.get(getUri, headers: _serverAuthHeaders());
        }

        if (response.statusCode < 200 || response.statusCode >= 300) continue;

        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) continue;
        final filesRaw = decoded['files'];
        if (filesRaw is! List) continue;

        final files = filesRaw
            .whereType<String>()
            .where(_isImagePath)
            .toList()
          ..sort();

        if (files.isEmpty) continue;

        return files
            .map((fileName) {
              final objectPath = '${widget.folderPath}/$fileName';
              final candidates = _apiImageUrlCandidates(
                objectPath,
                cacheVersion: _imageVersion,
              );
              return _GalleryImageItem(
                path: candidates.first,
                isAsset: false,
                objectPath: objectPath,
              );
            })
            .toList();
      } catch (_) {
        // Sigue con siguiente API base.
      }
    }

    return const [];
  }

  Future<List<_GalleryImageItem>> _loadImagesFromHttpGallery() async {
    try {
      final aliases = _folderAliases(widget.folderPath);

      for (final baseUrl in _galleryBaseUrls) {
        for (final alias in aliases) {
          final imageUrls = await _tryReadApacheIndex(baseUrl, alias);
          if (imageUrls.isNotEmpty) {
            return imageUrls
                .map((url) {
                  final uri = Uri.parse(url);
                  final fileName = uri.pathSegments.isNotEmpty
                      ? uri.pathSegments.last // pathSegments ya vienen decodificados
                      : 'imagen.jpg';
                  return _GalleryImageItem(
                    path: url,
                    isAsset: false,
                    objectPath: '$alias/$fileName',
                  );
                })
                .toList();
          }
        }
      }
    } catch (e, stack) {
      debugPrint('Error en _loadImagesFromHttpGallery: $e\\n$stack');
    }

    return const [];
  }

  List<String> _folderAliases(String original) {
    final normalized = _removeDiacritics(original);
    final variants = <String>{
      original,
      normalized,
      original.replaceAll('_', ' '),
      normalized.replaceAll('_', ' '),
      original.replaceAll('_', '-'),
      normalized.replaceAll('_', '-'),
      original.replaceAll('-', ' '),
      normalized.replaceAll('-', ' '),
      original.replaceAll(' ', '_'),
      normalized.replaceAll(' ', '_'),
      original.replaceAll(' ', '-'),
      normalized.replaceAll(' ', '-'),
    };

    final extra = <String>{};
    for (final value in variants) {
      extra.add(value.toLowerCase());
      extra.add(_toTitleCase(value));
    }
    variants.addAll(extra);

    return variants.where((value) => value.trim().isNotEmpty).toList();
  }

  String _removeDiacritics(String value) {
    const replacements = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'Á': 'A',
      'É': 'E',
      'Í': 'I',
      'Ó': 'O',
      'Ú': 'U',
      'ñ': 'n',
      'Ñ': 'N',
    };

    var output = value;
    replacements.forEach((source, target) {
      output = output.replaceAll(source, target);
    });
    return output;
  }

  String _toTitleCase(String value) {
    return value
        .split(' ')
        .map((part) {
          if (part.isEmpty) return part;
          final head = part[0].toUpperCase();
          final tail = part.length > 1 ? part.substring(1).toLowerCase() : '';
          return '$head$tail';
        })
        .join(' ');
  }

  Future<List<String>> _tryReadApacheIndex(String baseUrl, String folderName) async {
    final encodedFolder = Uri.encodeComponent(folderName);
    final directoryUrl = '$baseUrl/$encodedFolder/';

    try {
      final html = await NetworkAssetBundle(Uri.parse(directoryUrl)).loadString('');

      if (!html.contains('Index of')) return const [];

      final hrefRegex = RegExp(r'href="([^"]+)"', caseSensitive: false);
      final imageNames = <String>[];

      for (final match in hrefRegex.allMatches(html)) {
        final href = match.group(1);
        if (href == null || href.isEmpty) continue;
        if (href.startsWith('?') || href == '../') {
          continue;
        }

        if (href.startsWith('http://') || href.startsWith('https://')) {
          final uri = Uri.tryParse(href);
          if (uri == null || uri.pathSegments.isEmpty) continue;
          final fileName = Uri.decodeComponent(uri.pathSegments.last);
          if (_isImagePath(fileName)) {
            imageNames.add(fileName);
          }
          continue;
        }

        if (href.startsWith('/')) {
          final uri = Uri.tryParse(href);
          if (uri == null || uri.pathSegments.isEmpty) continue;
          final fileName = Uri.decodeComponent(uri.pathSegments.last);
          if (_isImagePath(fileName)) {
            imageNames.add(fileName);
          }
          continue;
        }

        final decodedName = Uri.decodeComponent(href);
        if (_isImagePath(decodedName)) {
          imageNames.add(decodedName);
        }
      }

      if (imageNames.isEmpty) return const [];

      imageNames.sort();
      return imageNames
          .map((name) => '$baseUrl/$encodedFolder/${Uri.encodeComponent(name)}')
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<_GalleryImageItem>> _loadImagesFromAssets() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final manifest = jsonDecode(manifestContent) as Map<String, dynamic>;
      final prefix = 'assets/images/${widget.folderPath}/';

      final assetPaths = manifest.keys
          .where(
            (path) => path.startsWith(prefix) && _isImagePath(path),
          )
          .toList()
        ..sort();

      return assetPaths
          .map((path) => _GalleryImageItem(path: path, isAsset: true))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<_SupabaseGalleryLoad?> _loadImagesFromSupabase() async {
    final client = Supabase.instance.client;

    for (final bucket in _bucketCandidates) {
      try {
        final items = await client.storage.from(bucket).list(
              path: widget.folderPath,
              searchOptions: const SearchOptions(limit: 200),
            );

        final files = items.where((item) => _isImagePath(item.name)).toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        if (files.isEmpty) continue;

        final images = files
            .map(
              (file) {
                final objectPath = '${widget.folderPath}/${file.name}';
                return _GalleryImageItem(
                  path: client.storage.from(bucket).getPublicUrl(objectPath),
                  isAsset: false,
                  bucket: bucket,
                  objectPath: objectPath,
                );
              },
            )
            .toList();

        return _SupabaseGalleryLoad(bucket: bucket, images: images);
      } catch (_) {
        // Si el bucket no existe o no tiene permisos de list, sigue con el siguiente.
      }
    }

    return null;
  }

  List<String> _publicUrlCandidates(String objectPath, {int? cacheVersion}) {
    final encodedPath = objectPath
        .split('/')
        .where((part) => part.trim().isNotEmpty)
        .map(Uri.encodeComponent)
        .join('/');

    final prioritizedBaseUrls = [..._galleryBaseUrls]
      ..sort((a, b) {
        final aScore = a.toLowerCase().contains('galeria') ? 0 : 1;
        final bScore = b.toLowerCase().contains('galeria') ? 0 : 1;
        return aScore.compareTo(bScore);
      });

    return prioritizedBaseUrls.map((baseUrl) {
      final cleanBase = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;
      final versionQuery = cacheVersion == null ? '' : '?v=$cacheVersion';
      return '$cleanBase/$encodedPath$versionQuery';
    }).toList();
  }

  List<String> _apiImageUrlCandidates(String objectPath, {int? cacheVersion}) {
    final encodedObjectPath = objectPath
        .split('/')
        .where((part) => part.trim().isNotEmpty)
        .map(Uri.encodeComponent)
        .join('/');

    final apiUrls = _galleryApiBaseUrls.map((apiBase) {
      final cleanBase = apiBase.endsWith('/')
          ? apiBase.substring(0, apiBase.length - 1)
          : apiBase;
      final versionQuery = cacheVersion == null ? '' : '&v=$cacheVersion';
      return '$cleanBase/files/raw?path=$encodedObjectPath$versionQuery';
    }).toList();

    return [
      ...apiUrls,
      ..._publicUrlCandidates(objectPath, cacheVersion: cacheVersion),
    ];
  }

  Uri _buildEncodedServerUri(String baseUrl, String objectPath) {
    final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final parts = objectPath
        .split('/')
        .where((part) => part.trim().isNotEmpty)
        .map(Uri.encodeComponent)
        .join('/');
    return Uri.parse('$cleanBase/$parts');
  }

  Future<bool> _writeToServer({
    required String method,
    required String objectPath,
    Uint8List? bytes,
    String? contentType,
    String? destinationPath,
  }) async {
    final headersBase = _serverAuthHeaders();

    for (final baseUrl in _galleryBaseUrls) {
      final uri = _buildEncodedServerUri(baseUrl, objectPath);
      final request = http.Request(method, uri);
      request.headers.addAll(headersBase);
      if (contentType != null) {
        request.headers['Content-Type'] = contentType;
      }
      if (destinationPath != null && method == 'MOVE') {
        final destinationUri = _buildEncodedServerUri(baseUrl, destinationPath);
        request.headers['Destination'] = destinationUri.toString();
        request.headers['Overwrite'] = 'T';
      }
      if (bytes != null) {
        request.bodyBytes = bytes;
      }

      try {
        final response = await request.send();
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return true;
        }
      } catch (_) {
        // Probar siguiente base.
      }
    }

    return false;
  }

  Future<bool> _tryApiJsonAction({
    required String endpoint,
    required Map<String, dynamic> payload,
  }) async {
    final headers = {
      ..._serverAuthHeaders(),
      'Content-Type': 'application/json',
    };

    for (final baseUrl in _galleryApiBaseUrls) {
      final cleanBase = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;
      final uri = Uri.parse('$cleanBase/$endpoint');
      try {
        final response = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(payload),
        );
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return true;
        }
      } catch (_) {
        // Intenta con el siguiente endpoint.
      }
    }

    return false;
  }

  Future<bool> _tryApiUploadAction({
    required String objectPath,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final headers = _serverAuthHeaders();

    for (final baseUrl in _galleryApiBaseUrls) {
      final cleanBase = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;
      final uri = Uri.parse('$cleanBase/files/upload');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      request.fields['path'] = objectPath;
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));

      try {
        final response = await request.send();
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return true;
        }
      } catch (_) {
        // Intenta con el siguiente endpoint.
      }
    }

    return false;
  }

  Future<XFile?> _pickImageFromGallery() async {
    try {
      return await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 92);
    } catch (_) {
      return null;
    }
  }

  String _fileExtension(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return 'jpg';
    return fileName.substring(dot + 1).toLowerCase();
  }

  String _mimeTypeForExtension(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpeg':
      case 'jpg':
      default:
        return 'image/jpeg';
    }
  }

  String _basename(String path) {
    final parts = path.split('/');
    return parts.isEmpty ? path : parts.last;
  }

  void _showGalleryMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  Future<String?> _promptText({
    required String title,
    required String hint,
    String? initialValue,
    String confirmLabel = 'Aceptar',
  }) async {
    final controller = TextEditingController(text: initialValue ?? '');
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: hint),
          maxLines: 3,
          minLines: 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return value?.trim();
  }

  Future<void> _uploadImage() async {
    if (!_isAdmin || _isProcessing) return;

    final file = await _pickImageFromGallery();
    if (file == null) return;

    final description = await _promptText(
      title: 'Descripción de la imagen',
      hint: 'Opcional: Añade un texto o contexto a esta foto...',
      confirmLabel: 'Subir foto',
    );
    if (description == null) return; // El usuario canceló

    final extension = _fileExtension(file.name);
    final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final objectPath = '${widget.folderPath}/$fileName';
    final bytes = await file.readAsBytes();

    await _uploadToStorage(
      objectPath: objectPath,
      bytes: bytes,
      extension: extension,
      successMessage: 'Imagen subida correctamente al servidor.',
    );

    if (description.isNotEmpty) {
      try {
        await Supabase.instance.client.from('gallery_metadata').insert({
          'image_path': objectPath,
          'description': description,
        });
      } catch (e) {
        debugPrint('Error al guardar la descripción en Supabase: $e');
      }
    }
  }

  Future<void> _replaceImage(_GalleryImageItem item) async {
    if (!_isAdmin || _isProcessing || !item.canBeManaged) return;

    final file = await _pickImageFromGallery();
    if (file == null) return;

    final targetPath = item.objectPath!;
    final extension = _fileExtension(file.name);
    final bytes = await file.readAsBytes();

    await _uploadToStorage(
      objectPath: targetPath,
      bytes: bytes,
      extension: extension,
      successMessage: 'Imagen reemplazada correctamente.',
    );
  }

  Future<void> _uploadToStorage({
    required String objectPath,
    required Uint8List bytes,
    required String extension,
    required String successMessage,
  }) async {
    setState(() {
      _isProcessing = true;
    });

    final ok = await _writeToServer(
      method: 'PUT',
      objectPath: objectPath,
      bytes: bytes,
      contentType: _mimeTypeForExtension(extension),
    );

    final uploaded =
        await _tryApiUploadAction(
          objectPath: objectPath,
          bytes: bytes,
          fileName: _basename(objectPath),
        ) ||
        ok;

    if (uploaded) {
      _showGalleryMessage(successMessage);
      await _loadImages();
    } else {
      _showGalleryMessage(
        'No se pudo completar la operación en el servidor.',
        isError: true,
      );
    }

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _deleteImage(_GalleryImageItem item) async {
    if (!_isAdmin || _isProcessing || !item.canBeManaged) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar imagen'),
        content: const Text('Esta acción no se puede deshacer. ¿Deseas continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isProcessing = true;
    });

    final deleted =
        await _tryApiJsonAction(
          endpoint: 'files/delete',
          payload: {'path': item.objectPath!},
        ) ||
        await _writeToServer(
          method: 'DELETE',
          objectPath: item.objectPath!,
        );

    if (deleted) {
      _showGalleryMessage('Imagen eliminada correctamente.');
      try {
        await Supabase.instance.client.from('gallery_metadata').delete().eq('image_path', item.objectPath!);
      } catch (_) {}
      await _loadImages();
    } else {
      _showGalleryMessage('No se pudo eliminar la imagen en el servidor.', isError: true);
    }

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _editDescription(_GalleryImageItem item) async {
    if (!_isAdmin || !item.canBeManaged) return;
    
    setState(() => _isProcessing = true);
    
    String currentDescription = '';
    try {
      final res = await Supabase.instance.client
          .from('gallery_metadata')
          .select('description')
          .eq('image_path', item.objectPath!)
          .maybeSingle();
      if (res != null) {
        currentDescription = res['description'] as String;
      }
    } catch (_) {}

    setState(() => _isProcessing = false);

    final newDescription = await _promptText(
      title: 'Editar descripción',
      hint: 'Escribe el contexto o descripción de la foto',
      initialValue: currentDescription,
      confirmLabel: 'Guardar',
    );

    if (newDescription == null) return;

    setState(() => _isProcessing = true);

    if (newDescription.trim().isEmpty) {
      try {
        await Supabase.instance.client
            .from('gallery_metadata')
            .delete()
            .eq('image_path', item.objectPath!);
        _showGalleryMessage('Descripción eliminada');
      } catch (_) {
        _showGalleryMessage('No se pudo eliminar la descripción', isError: true);
      }
    } else {
      try {
        await Supabase.instance.client.from('gallery_metadata').upsert({
          'image_path': item.objectPath!,
          'description': newDescription.trim(),
        });
        _showGalleryMessage('Descripción guardada correctamente');
      } catch (_) {
        _showGalleryMessage('No se pudo guardar la descripción', isError: true);
      }
    }

    setState(() => _isProcessing = false);
  }

  bool _isImagePath(String value) {
    final lower = value.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: widget.color,
        title: Text(
          widget.folderTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B5000), Color(0xFFD4AF5A), Color(0xFF6B5000)],
              ),
            ),
          ),
        ),
        actions: [
          if (_isAdmin)
            PopupMenuButton<String>(
              enabled: !_isProcessing,
              icon: const Icon(Icons.admin_panel_settings_rounded),
              tooltip: 'Acciones de admin',
              onSelected: (value) {
                if (value == 'upload') _uploadImage();
              },
              itemBuilder: (_) => const [
                PopupMenuItem<String>(
                  value: 'upload',
                  child: ListTile(
                    leading: Icon(Icons.add_photo_alternate_rounded),
                    title: Text('Subir imagen'),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Header de carpeta ──────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.color, widget.color.withValues(alpha: 0.72)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.22),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.folder_rounded, color: Colors.white, size: 30),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.folderTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Colección visual histórica',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.78),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Carpeta: ${widget.folderPath}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 12,
                        ),
                      ),
                      if (_isAdmin) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Modo administrador activo (CRUD habilitado)',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // ── Contenido ─────────────────────────────────────────
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_loadError != null)
                SliverFillRemaining(
                  child: _GalleryMessageCard(
                    color: widget.color,
                    icon: Icons.cloud_off_rounded,
                    title: 'Error de carga',
                    message: _loadError!,
                    actionLabel: 'Reintentar',
                    onAction: _loadImages,
                  ),
                )
              else if (_images.isEmpty)
                SliverFillRemaining(
                  child: _GalleryMessageCard(
                    color: widget.color,
                    icon: Icons.photo_library_outlined,
                    title: 'Sin imágenes',
                    message:
                        'No se encontraron imágenes publicadas para esta carpeta. Verifica acceso HTTP al directorio del servidor para ${widget.folderPath}.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = _images[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Material(
                            color: Colors.white,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => _GalleryPreviewScreen(
                                      item: item,
                                      title: widget.folderTitle,
                                      color: widget.color,
                                    ),
                                  ),
                                );
                              },
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  item.isAsset
                                      ? Image.asset(
                                          item.path,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => _ImageErrorTile(color: widget.color),
                                        )
                                      : Image.network(
                                          item.path,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, progress) {
                                            if (progress == null) return child;
                                            return const Center(
                                              child: CircularProgressIndicator(strokeWidth: 2.2),
                                            );
                                          },
                                          errorBuilder: (_, __, ___) => _ImageErrorTile(color: widget.color),
                                        ),
                                  if (_isAdmin && item.canBeManaged)
                                    Positioned(
                                      bottom: 8, right: 8,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.55),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: PopupMenuButton<String>(
                                          enabled: !_isProcessing,
                                          icon: const Icon(Icons.more_vert, color: Colors.white),
                                          onSelected: (value) {
                                            if (value == 'edit_desc') {
                                              _editDescription(item);
                                            } else if (value == 'replace') {
                                              _replaceImage(item);
                                            } else if (value == 'delete') {
                                              _deleteImage(item);
                                            }
                                          },
                                          itemBuilder: (_) => const [
                                            PopupMenuItem<String>(
                                              value: 'edit_desc',
                                              child: ListTile(
                                                leading: Icon(Icons.description_rounded),
                                                title: Text('Editar descripción'),
                                              ),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'replace',
                                              child: ListTile(
                                                leading: Icon(Icons.edit_rounded),
                                                title: Text('Reemplazar foto'),
                                              ),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'delete',
                                              child: ListTile(
                                                leading: Icon(Icons.delete_rounded, color: Colors.red),
                                                title: Text('Eliminar foto'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _images.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                  ),
                ),
            ],
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.18),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _SupabaseGalleryLoad {
  final String bucket;
  final List<_GalleryImageItem> images;

  const _SupabaseGalleryLoad({required this.bucket, required this.images});
}

class _GalleryImageItem {
  final String path;
  final bool isAsset;
  final String? bucket;
  final String? objectPath;

  const _GalleryImageItem({
    required this.path,
    required this.isAsset,
    this.bucket,
    this.objectPath,
  });

  bool get canBeManaged => objectPath != null && !isAsset;
}

class _GalleryMessageCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _GalleryMessageCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
              ),
              child: Icon(icon, size: 46, color: color),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blueGrey[700],
                height: 1.45,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ImageErrorTile extends StatelessWidget {
  final Color color;

  const _ImageErrorTile({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withValues(alpha: 0.08),
      child: Icon(Icons.broken_image_outlined, color: color, size: 36),
    );
  }
}

class _GalleryPreviewScreen extends StatelessWidget {
  final _GalleryImageItem item;
  final String title;
  final Color color;

  const _GalleryPreviewScreen({
    required this.item,
    required this.title,
    required this.color,
  });

  Future<String?> _fetchDescription() async {
    if (item.objectPath == null) return null;
    try {
      final res = await Supabase.instance.client
          .from('gallery_metadata')
          .select('description')
          .eq('image_path', item.objectPath!)
          .maybeSingle();
      return res?['description'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: color,
        title: Text(title),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 5,
              child: item.isAsset
                  ? Image.asset(item.path, fit: BoxFit.contain)
                  : Image.network(item.path, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FutureBuilder<String?>(
              future: _fetchDescription(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Container(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                    ),
                  ),
                  child: Text(
                    snapshot.data!,
                    style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _GoldChip({required this.icon, required this.label});

  static const Color _gold     = Color(0xFFB8973A);
  static const Color _goldLight = Color(0xFFD4AF5A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _goldLight.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _goldLight, size: 13),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _goldLight,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
