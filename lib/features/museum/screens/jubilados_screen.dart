import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:museo_app/features/admin/services/admin_service.dart';

class JubiladosScreen extends StatefulWidget {
  const JubiladosScreen({super.key});

  @override
  State<JubiladosScreen> createState() => _JubiladosScreenState();
}

class _JubiladosScreenState extends State<JubiladosScreen> {
  final AdminService _adminService = AdminService();
  final SupabaseClient _supabase = Supabase.instance.client;

  static const Color _navy = Color(0xFF1A2545);
  static const Color _cream = Color(0xFFF5F0E8);
  static const Color _gold = Color(0xFFB8973A);

  bool _isAdmin = false;
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;
  List<String> _currentOrder = [];
  List<String> _originalOrder = []; // Para cancelar cambios

  @override
  void initState() {
    super.initState();
    _checkAdminAndLoadOrder();
  }

  Future<void> _checkAdminAndLoadOrder() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      _isAdmin = await _adminService.isCurrentUserAdmin();

      final response = await _supabase
          .from('museum_config')
          .select('value')
          .eq('key', 'jubilados_order')
          .maybeSingle();

      if (response != null && response['value'] != null) {
        final List<dynamic> savedList = response['value'];
        final saved = savedList.map((e) => e.toString()).toList();
        // Agregar archivos nuevos que no estén en el orden guardado
        for (var file in _jubiladosImageFiles) {
          if (!saved.contains(file)) saved.add(file);
        }
        _currentOrder = saved;
      } else {
        _currentOrder = List.from(_jubiladosImageFiles);
      }
      _originalOrder = List.from(_currentOrder);
    } catch (e) {
      debugPrint('Error al cargar orden: $e');
      _currentOrder = List.from(_jubiladosImageFiles);
      _originalOrder = List.from(_currentOrder);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveOrder() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await _supabase.from('museum_config').upsert(
        {
          'key': 'jubilados_order',
          'value': _currentOrder,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'key',
      );

      _originalOrder = List.from(_currentOrder);

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Orden guardado globalmente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelEditing() {
    setState(() {
      _currentOrder = List.from(_originalOrder);
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _navy,
        title: const Text(
          'JUBILADOS',
          style: TextStyle(letterSpacing: 2.5, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isAdmin && !_isEditing)
            IconButton(
              icon: const Icon(Icons.swap_vert_rounded),
              tooltip: 'Reordenar imágenes',
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing) ...[
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
              )
            else ...[
              IconButton(
                icon: const Icon(Icons.close, color: Colors.redAccent),
                tooltip: 'Cancelar',
                onPressed: _cancelEditing,
              ),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.greenAccent),
                tooltip: 'Guardar orden',
                onPressed: _saveOrder,
              ),
            ],
          ],
        ],
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _gold))
          : _isEditing
              ? _buildReorderableList()
              : _buildPhotoGrid(),
    );
  }

  // ── Vista normal: grid de fotos ─────────────────────────────────────────────
  Widget _buildPhotoGrid() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _Header(total: _currentOrder.length)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _JubiladoPhotoCard(
                imageFile: _currentOrder[index],
              ),
              childCount: _currentOrder.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 20,
              childAspectRatio: 0.72,
            ),
          ),
        ),
      ],
    );
  }

  // ── Vista edición: lista drag & drop ───────────────────────────────────────
  Widget _buildReorderableList() {
    return Column(
      children: [
        // Banner informativo
        Container(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade400),
          ),
          child: Row(
            children: [
              Icon(Icons.drag_indicator, color: Colors.amber.shade700),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Arrastra las filas para reordenar. Toca ✓ para guardar.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
            itemCount: _currentOrder.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = _currentOrder.removeAt(oldIndex);
                _currentOrder.insert(newIndex, item);
              });
            },
            proxyDecorator: (child, index, animation) {
              return Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(14),
                shadowColor: _navy.withValues(alpha: 0.4),
                child: child,
              );
            },
            itemBuilder: (context, index) {
              final imageFile = _currentOrder[index];
              return _ReorderableImageTile(
                key: ValueKey(imageFile),
                imageFile: imageFile,
                index: index,
                total: _currentOrder.length,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Tile para la lista reordenable ──────────────────────────────────────────
class _ReorderableImageTile extends StatelessWidget {
  final String imageFile;
  final int index;
  final int total;

  const _ReorderableImageTile({
    super.key,
    required this.imageFile,
    required this.index,
    required this.total,
  });

  static const Color _navy = Color(0xFF1A2545);
  static const Color _gold = Color(0xFFB8973A);

  String get _imageUrl {
    final encoded = Uri.encodeComponent(imageFile);
    return 'http://64.23.168.72/media/Jubilados/$encoded';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _gold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Número de posición
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: _gold,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          // Miniatura
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              _imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 64, height: 64,
                color: const Color(0xFFEDE8DF),
                child: Icon(Icons.person, color: _gold.withValues(alpha: 0.5), size: 30),
              ),
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: 64, height: 64,
                  color: const Color(0xFFF0EBE0),
                  child: Center(child: CircularProgressIndicator(color: _gold, strokeWidth: 2)),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Nombre del archivo (simplificado)
          Expanded(
            child: Text(
              'Foto ${index + 1} de $total',
              style: const TextStyle(
                color: _navy,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Handle de arrastre (decorativo, el ReorderableListView lo maneja)
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.drag_handle, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Datos de imágenes
// ══════════════════════════════════════════════════════════════════════════════

const List<String> _jubiladosBaseUrls = [
  'http://64.23.168.72/media/Jubilados',
  'http://64.23.168.72/Jubilados',
  'https://64.23.168.72/media/Jubilados',
  'https://64.23.168.72/Jubilados',
];

const List<String> _jubiladosImageFiles = [
  'WhatsApp Image 2026-04-07 at 17.02.51 (1).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.56 (3).jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.38 (3).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.51.jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.56 (4).jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.38 (4).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.52 (1).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.56.jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.38 (5).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.52 (2).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.57 (1).jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.38.jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.52 (3).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.57 (2).jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.39 (1).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.52 (4).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.57 (3).jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.39 (2).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.52.jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.57 (4).jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.39 (3).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.53 (1).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.57.jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.39 (4).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.53 (2).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.58.jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.39 (5).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.53.jpeg',
  'WhatsApp Image 2026-04-07 at 17.04.30.jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.39 (6).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.55 (1).jpeg',
  'WhatsApp Image 2026-04-07 at 17.04.31.jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.39 (7).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.55 (2).jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.37 (1).jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.39 (8).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.55.jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.37.jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.39.jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.56 (1).jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.38 (1).jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.40.jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.56 (2).jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.38 (2).jpeg',
];

// ── Header del museo ────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final int total;
  const _Header({required this.total});

  static const Color _navy = Color(0xFF1A2545);
  static const Color _gold = Color(0xFFB8973A);
  static const Color _goldLight = Color(0xFFD4AF5A);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2545), Color(0xFF2C3E6B), Color(0xFF1A2545)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30, right: -30,
            child: Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          Positioned(
            bottom: -20, left: -20,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gold.withValues(alpha: 0.07),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: _gold.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _gold.withValues(alpha: 0.5), width: 1.5),
                      ),
                      child: const Icon(Icons.groups_rounded, color: _goldLight, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'GALERÍA DE HONOR',
                          style: TextStyle(
                            color: _goldLight, fontSize: 10,
                            fontWeight: FontWeight.w700, letterSpacing: 2.5,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Jubilados UM',
                          style: TextStyle(
                            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(width: 36, height: 1, color: _gold.withValues(alpha: 0.6)),
                    Container(
                      width: 5, height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: _gold),
                    ),
                    Expanded(child: Container(height: 1, color: _gold.withValues(alpha: 0.25))),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Reconociendo la trayectoria y servicio de quienes dedicaron su vida a la Universidad de Montemorelos.',
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _gold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_library_outlined, color: _goldLight, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        '$total retratos',
                        style: const TextStyle(
                          color: _goldLight, fontSize: 12, fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta de retrato (vista grid normal) ──────────────────────────────────
class _JubiladoPhotoCard extends StatefulWidget {
  final String imageFile;

  const _JubiladoPhotoCard({required this.imageFile});

  @override
  State<_JubiladoPhotoCard> createState() => _JubiladoPhotoCardState();
}

class _JubiladoPhotoCardState extends State<_JubiladoPhotoCard> {
  static const Color _navy = Color(0xFF1A2545);
  static const Color _gold = Color(0xFFB8973A);

  int _baseUrlIndex = 0;

  String get _currentImageUrl {
    final encodedFile = Uri.encodeComponent(widget.imageFile);
    return '${_jubiladosBaseUrls[_baseUrlIndex]}/$encodedFile';
  }

  void _useNextUrl() {
    if (_baseUrlIndex < _jubiladosBaseUrls.length - 1) {
      setState(() => _baseUrlIndex++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: [
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6B5000), Color(0xFFD4AF5A), Color(0xFF6B5000)],
                ),
              ),
            ),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _currentImageUrl,
                    key: ValueKey(_currentImageUrl),
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: const Color(0xFFF0EBE0),
                        child: Center(
                          child: CircularProgressIndicator(color: _gold, strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      if (_baseUrlIndex < _jubiladosBaseUrls.length - 1) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) _useNextUrl();
                        });
                        return Container(
                          color: const Color(0xFFF0EBE0),
                          child: Center(
                            child: CircularProgressIndicator(color: _gold, strokeWidth: 2),
                          ),
                        );
                      }
                      return Container(
                        color: const Color(0xFFEDE8DF),
                        child: Icon(Icons.person, size: 56, color: _gold.withValues(alpha: 0.4)),
                      );
                    },
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.1,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    height: 2, width: 28,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB8973A), Color(0xFFD4AF5A)],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Memorias del museo',
                    style: TextStyle(
                      color: _navy, fontSize: 11,
                      fontWeight: FontWeight.w600, letterSpacing: 0.3, height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
