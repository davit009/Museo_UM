import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const List<String> _galleryBaseUrls = [
  'http://64.23.168.72/media',
  'http://64.23.168.72',
  'http://64.23.168.72/media/Galeria',
  'http://64.23.168.72/Galeria',
  'http://64.23.168.72/media/Galerias',
  'http://64.23.168.72/Galerias',
];

class ImagesScreen extends StatelessWidget {
  const ImagesScreen({super.key});

  static const Color _navy  = Color(0xFF0F1C35);
  static const Color _cream = Color(0xFFF5F0E8);

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
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _GalleryHero(total: _imageFolders.length)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final folder = _imageFolders[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _FolderCard(
                      title: folder['title'] as String,
                      subtitle: folder['subtitle'] as String,
                      icon: folder['icon'] as IconData,
                      color: folder['color'] as Color,
                      folderPath: folder['path'] as String,
                      index: index,
                    ),
                  );
                },
                childCount: _imageFolders.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero banner ──────────────────────────────────────────────────────────────
class _GalleryHero extends StatelessWidget {
  final int total;
  const _GalleryHero({required this.total});

  static const Color _gold      = Color(0xFFB8973A);
  static const Color _goldLight = Color(0xFFD4AF5A);

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Positioned(
            bottom: -30, left: -30,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
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
                const SizedBox(height: 20),
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
                const SizedBox(height: 16),
                const Text(
                  'Explora el archivo visual del museo con colecciones organizadas por época, institución y memoria histórica.',
                  style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.65),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroChip(icon: Icons.collections_rounded, label: '$total colecciones'),
                    const _HeroChip(icon: Icons.timeline_rounded, label: 'Archivo histórico'),
                    const _HeroChip(icon: Icons.camera_alt_rounded, label: 'Fotografía'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroChip({required this.icon, required this.label});

  static const Color _gold      = Color(0xFFB8973A);
  static const Color _goldLight = Color(0xFFD4AF5A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _goldLight, size: 13),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: _goldLight, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

final List<Map<String, dynamic>> _imageFolders = [
  {
    'title': '1894 Iglesia',
    'subtitle': 'Educación religiosa en Tacubaya',
    'path': '1894-iglesia-Educación',
    'icon': Icons.church,
    'color': Color(0xFF8B4513),
  },
  {
    'title': '1921 Instituto',
    'subtitle': 'Instituto Comercial Prosperidad',
    'path': '1921-42-Instituto Comercial Prosperidad',
    'icon': Icons.school,
    'color': Color(0xFF1B5E75),
  },
  {
    'title': '1942 Escuela Agrícola',
    'subtitle': 'Escuela Agrícola Industrial Mexicana',
    'path': '1942-51-Escuela Agricola Industrial Mexicana',
    'icon': Icons.agriculture,
    'color': Color(0xFF2D5016),
  },
  {
    'title': '1946 Hospital',
    'subtitle': 'Servicios de salud universitarios',
    'path': '1946-Hospital',
    'icon': Icons.local_hospital,
    'color': Color(0xFFC32F27),
  },
  {
    'title': '1951 COVOPROM',
    'subtitle': 'Colegio Vocacional y Profesional',
    'path': '1951-72-Covoprom',
    'icon': Icons.business,
    'color': Color(0xFF7B5EA7),
  },
  {
    'title': '1972 Universidad',
    'subtitle': 'Primeros años universitarios',
    'path': '1972-Universidad',
    'icon': Icons.library_books,
    'color': Color(0xFF1A2B4A),
  },
  {
    'title': '1973 Universidad',
    'subtitle': 'Decreto oficial de fundación UM',
    'path': '1973-Universidad',
    'icon': Icons.account_balance,
    'color': Color(0xFF2E7D9A),
  },
  {
    'title': '2014 UM Vídeo',
    'subtitle': 'Registro audiovisual institucional',
    'path': '2014_UM_Video',
    'icon': Icons.videocam,
    'color': Color(0xFF5B6FA0),
  },
  {
    'title': '2018 Actividades',
    'subtitle': 'Eventos y vida universitaria',
    'path': '2018-04-11',
    'icon': Icons.event,
    'color': Color(0xFF1B9E8A),
  },
  {
    'title': 'Directores Institución',
    'subtitle': 'Galería de directores históricos',
    'path': 'Directores-Institución',
    'icon': Icons.person_pin,
    'color': Color(0xFFC9961A),
  },
  {
    'title': 'Directores',
    'subtitle': 'Líderes que forjaron la universidad',
    'path': 'Directores',
    'icon': Icons.people,
    'color': Color(0xFF5A3A5A),
  },
  {
    'title': 'Logos Institución',
    'subtitle': 'Evolución de la identidad visual',
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

  static const Color _navy = Color(0xFF0F1C35);
  static const Color _gold = Color(0xFFB8973A);

  const _FolderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.folderPath,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Extraer el año del título si empieza con dígitos
    final yearMatch = RegExp(r'^\d{4}').firstMatch(title);
    final year = yearMatch != null ? yearMatch.group(0)! : '';
    final titleRest = year.isNotEmpty ? title.substring(4).trim() : title;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _gold.withValues(alpha: 0.22)),
            boxShadow: [
              BoxShadow(
                color: _navy.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(child: Row(
              children: [
                // Bloque izquierdo con color + ícono
                Container(
                  width: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.75)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Icon(icon, color: Colors.white, size: 26),
                      if (year.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          year,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                // Línea dorada separadora
                Container(
                  width: 2,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _gold.withValues(alpha: 0.6),
                        _gold.withValues(alpha: 0.2),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Contenido derecho
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          year.isNotEmpty ? titleRest : title,
                          style: const TextStyle(
                            color: _navy,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'Ver colección',
                              style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 11),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Número de índice decorativo
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Text(
                    (index + 1).toString().padLeft(2, '0'),
                    style: TextStyle(
                      color: _navy.withValues(alpha: 0.08),
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            )),
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

  final List<_GalleryImageItem> _images = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
      _images.clear();
    });

    try {
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
        _images.addAll(fromSupabase);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError =
            'No se pudieron cargar las imágenes. Revisa conexión y permisos de Storage.';
      });
    }
  }

  Future<List<_GalleryImageItem>> _loadImagesFromHttpGallery() async {
    final aliases = _folderAliases(widget.folderPath);

    for (final baseUrl in _galleryBaseUrls) {
      for (final alias in aliases) {
        final imageUrls = await _tryReadApacheIndex(baseUrl, alias);
        if (imageUrls.isNotEmpty) {
          return imageUrls
              .map((url) => _GalleryImageItem(path: url, isAsset: false))
              .toList();
        }
      }
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
        if (href.startsWith('?') || href.startsWith('/') || href == '../') {
          continue;
        }

        final decodedName = Uri.decodeComponent(href);
        if (!_isImagePath(decodedName)) continue;
        imageNames.add(decodedName);
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

  Future<List<_GalleryImageItem>> _loadImagesFromSupabase() async {
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

        return files
            .map(
              (file) => _GalleryImageItem(
                path: client.storage
                    .from(bucket)
                    .getPublicUrl('${widget.folderPath}/${file.name}'),
                isAsset: false,
              ),
            )
            .toList();
      } catch (_) {
        // Si el bucket no existe o no tiene permisos de list, sigue con el siguiente.
      }
    }

    return const [];
  }

  bool _isImagePath(String value) {
    final lower = value.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
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
              color: widget.color.withValues(alpha: 0.18),
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
                  width: 52,
                  height: 52,
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
                          fontSize: 22,
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
            const SizedBox(height: 16),
            Text(
              'Carpeta: ${widget.folderPath}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: widget.color,
        title: Text(widget.folderTitle),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
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
                    'No se encontraron imágenes publicadas para esta carpeta. '
                    'Verifica que exista acceso HTTP al directorio del servidor para ${widget.folderPath}.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
                          child: item.isAsset
                              ? Image.asset(
                                  item.path,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _ImageErrorTile(color: widget.color),
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
                                  errorBuilder: (_, __, ___) =>
                                      _ImageErrorTile(color: widget.color),
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
    );
  }
}

class _GalleryImageItem {
  final String path;
  final bool isAsset;

  const _GalleryImageItem({required this.path, required this.isAsset});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: color,
        title: Text(title),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 5,
          child: item.isAsset
              ? Image.asset(item.path, fit: BoxFit.contain)
              : Image.network(item.path, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

