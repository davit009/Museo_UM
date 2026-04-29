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
  List<String> _currentOrder = [];

  @override
  void initState() {
    super.initState();
    _checkAdminAndLoadOrder();
  }

  Future<void> _checkAdminAndLoadOrder() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // 1. Verificar si el usuario es administrador
      _isAdmin = await _adminService.isCurrentUserAdmin();

      // 2. Intentar cargar el orden guardado desde Supabase
      final response = await _supabase
          .from('museum_config')
          .select('value')
          .eq('key', 'jubilados_order')
          .maybeSingle();

      if (response != null && response['value'] != null) {
        final List<dynamic> savedList = response['value'];
        _currentOrder = savedList.map((e) => e.toString()).toList();
        
        // Sincronizar con archivos locales por si se añadieron nuevos
        for (var file in _jubiladosImageFiles) {
          if (!_currentOrder.contains(file)) {
            _currentOrder.add(file);
          }
        }
      } else {
        _currentOrder = List.from(_jubiladosImageFiles);
      }
    } catch (e) {
      debugPrint('Error al cargar orden: $e');
      _currentOrder = List.from(_jubiladosImageFiles);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveOrder() async {
    setState(() => _isLoading = true);
    try {
      await _supabase.from('museum_config').upsert({
        'key': 'jubilados_order',
        'value': _currentOrder,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Orden guardado globalmente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _moveImage(int index, int delta) {
    final newIndex = index + delta;
    if (newIndex >= 0 && newIndex < _currentOrder.length) {
      setState(() {
        final item = _currentOrder.removeAt(index);
        _currentOrder.insert(newIndex, item);
      });
    }
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
              icon: const Icon(Icons.edit_note),
              tooltip: 'Reacomodar imágenes',
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.close, color: Colors.redAccent),
              onPressed: () {
                _checkAdminAndLoadOrder(); // Recargar para cancelar cambios
                setState(() => _isEditing = false);
              },
            ),
            IconButton(
              icon: const Icon(Icons.check, color: Colors.greenAccent),
              onPressed: _saveOrder,
            ),
          ]
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
        : CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header(total: _currentOrder.length)),
              if (_isEditing)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.shade700),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Modo Administrador: Usa las flechas para mover las imágenes. No olvides guardar al finalizar.',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final imageFile = _currentOrder[index];
                      return _JubiladoPhotoCard(
                        bottomLabel: 'Memorias del museo',
                        imageFile: imageFile,
                        isEditing: _isEditing,
                        onMoveLeft: index > 0 ? () => _moveImage(index, -1) : null,
                        onMoveRight: index < _currentOrder.length - 1 ? () => _moveImage(index, 1) : null,
                      );
                    },
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
          ),
    );
  }
}

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
                        border: Border.all(
                          color: _gold.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(Icons.groups_rounded, color: _goldLight, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GALERÍA DE HONOR',
                          style: TextStyle(
                            color: _goldLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Jubilados UM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
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
                          color: _goldLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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

// ── Tarjeta de retrato ───────────────────────────────────────────────────────
class _JubiladoPhotoCard extends StatefulWidget {
  final String bottomLabel;
  final String imageFile;
  final bool isEditing;
  final VoidCallback? onMoveLeft;
  final VoidCallback? onMoveRight;

  const _JubiladoPhotoCard({
    required this.bottomLabel,
    required this.imageFile,
    this.isEditing = false,
    this.onMoveLeft,
    this.onMoveRight,
  });

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
        border: Border.all(
          color: widget.isEditing ? Colors.amber : _gold.withValues(alpha: 0.30), 
          width: widget.isEditing ? 2 : 1
        ),
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
            // Franja dorada superior
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6B5000), Color(0xFFD4AF5A), Color(0xFF6B5000)],
                ),
              ),
            ),
            // Imagen
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
                          child: CircularProgressIndicator(
                            color: _gold,
                            strokeWidth: 2,
                          ),
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
                  // Viñeta sutil en bordes
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
                  // Controles de edición
                  if (widget.isEditing)
                    Container(
                      color: Colors.black26,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (widget.onMoveLeft != null)
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back, color: _navy),
                                onPressed: widget.onMoveLeft,
                              ),
                            ),
                          if (widget.onMoveRight != null)
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_forward, color: _navy),
                                onPressed: widget.onMoveRight,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Sección del nombre
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    height: 2,
                    width: 28,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB8973A), Color(0xFFD4AF5A)],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.bottomLabel,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      height: 1.3,
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

