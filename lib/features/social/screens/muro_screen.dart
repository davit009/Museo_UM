import 'package:flutter/material.dart';
import 'package:museo_app/features/social/services/muro_service.dart';
import 'package:museo_app/features/social/services/social_service.dart';
import 'package:museo_app/features/auth/screens/login_screen.dart';
import 'package:museo_app/features/social/widgets/connect_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:museo_app/features/social/screens/comments_bottom_sheet.dart';

class MuroScreen extends StatefulWidget {
  const MuroScreen({super.key});

  @override
  State<MuroScreen> createState() => _MuroScreenState();
}

class _MuroScreenState extends State<MuroScreen> {
  static const Color _color = Color(0xFFE04E4E);

  final _muroService = MuroService();
  final _textController = TextEditingController();
  final _textFocusNode = FocusNode();
  List<Map<String, dynamic>> _posts = [];
  Map<String, dynamic>? _myProfile;
  String _currentFilter = 'Todos'; // Comunidad
  String _currentCategoryFilter = 'Todas'; // Categoria
  String _selectedNewPostCategory = 'General';
  
  final List<String> _categorias = ['Todas', 'General', 'Duda', 'Aviso', 'Empleo', 'Proyecto'];
  final List<String> _categoriasPost = ['General', 'Duda', 'Aviso', 'Empleo', 'Proyecto'];

  bool _isLoading = true;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final posts = await _muroService.fetchPosts();
      final myProfile = await _muroService.getMyProfile();
      setState(() {
        _posts = posts;
        _myProfile = myProfile;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredPosts {
    if (_posts.isEmpty) return [];
    
    return _posts.where((post) {
      final perfil = post['profiles'];
      if (perfil == null) return false;
      if (_myProfile != null) {
        if (_currentFilter == 'Mi Carrera') {
          if (perfil['carrera'] != _myProfile!['carrera']) return false;
        } else if (_currentFilter == 'Mi Generación') {
          if (perfil['generacion'] != _myProfile!['generacion']) return false;
        }
      }

      if (_currentCategoryFilter != 'Todas') {
        if (post['categoria'] != _currentCategoryFilter) return false;
      }

      return true;
    }).toList();
  }

  Future<void> _reaccionar(int postId, String reactionType) async {
    if (_muroService.currentUser == null) return;
    try {
      await _muroService.toggleReaction(postId, reactionType);
      await _loadPosts();
    } catch (_) {}
  }

  Future<void> _publicar() async {
    final texto = _textController.text.trim();
    if (texto.isEmpty) return;

    setState(() => _isPosting = true);
    try {
      await _muroService.createPost(texto, categoria: _selectedNewPostCategory);
      _textController.clear();
      setState(() => _selectedNewPostCategory = 'General');
      FocusScope.of(context).unfocus();
      await _loadPosts();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<void> _eliminar(int postId) async {
    try {
      await _muroService.deletePost(postId);
      await _loadPosts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatFecha(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final ahora = DateTime.now();
      final diff = ahora.difference(dt);
      if (diff.inMinutes < 1) return 'ahora';
      if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'hace ${diff.inHours} h';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  Future<void> _reportar(int postId) async {
    final reasonCtrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reportar publicación'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(hintText: '¿Cuál es el motivo del reporte?'),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, reasonCtrl.text),
            child: const Text('Enviar reporte', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      try {
        await Supabase.instance.client.from('reports').insert({
          'post_id': postId,
          'reporter_id': _muroService.currentUser!.id,
          'reason': result.trim()
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reporte enviado al administrador.', style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF1B9E8A)));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al procesar: ${e.toString().split("Exception: ").last}'), backgroundColor: Colors.red));
      }
    }
  }

  void _mostrarPerfil(BuildContext context, String targetUserId, Map<String, dynamic> perfil, bool esMio, bool estaLogueado) {
    final nombre = perfil['nombre'] as String? ?? perfil['username'] as String? ?? 'Visitante';
    final carrera = perfil['carrera'] as String? ?? 'Carrera no especificada';
    final generacion = perfil['generacion'] as String? ?? 'Generación no especificada';
    final biografia = perfil['biografia'] as String? ?? '';
    final esMentor = perfil['mentoria_abierta'] == true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              CircleAvatar(
                radius: 40,
                backgroundColor: _color.withValues(alpha: 0.15),
                child: Text(
                  nombre.isNotEmpty ? nombre[0].toUpperCase() : 'V',
                  style: const TextStyle(color: _color, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  if (esMentor) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF1B9E8A).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.school, size: 14, color: Color(0xFF1B9E8A)),
                          SizedBox(width: 4),
                          Text('Mentor', style: TextStyle(color: Color(0xFF1B9E8A), fontSize: 12, fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              if (carrera.isNotEmpty || generacion.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$carrera${generacion.isNotEmpty ? ' • $generacion' : ''}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (biografia.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  biografia,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              if (!esMio && estaLogueado) ...[
                SizedBox(
                  width: double.infinity,
                  child: ConnectButton(
                    targetUserId: targetUserId, 
                    targetUserName: nombre,
                    onConnectPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('¡Solicitud enviada a $nombre!'),
                          backgroundColor: const Color(0xFF1B9E8A),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await SocialService().blockUser(targetUserId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Has bloqueado a $nombre. Sus publicaciones y mensajes han sido ocultados.')),
                    );
                    _loadPosts(); 
                  },
                  icon: const Icon(Icons.block, color: Colors.red),
                  label: const Text('Bloquear Usuario', style: TextStyle(color: Colors.red)),
                )
              ],
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _muroService.currentUser?.id;
    final estaLogueado = currentUserId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: _color,
        title: const Text('Comunidad UM'),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPosts,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Banner ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE04E4E), Color(0xFF9B1A1A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.forum, color: Colors.white, size: 36),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comunidad',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Comparte, conecta y descubre con tu universidad',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Caja de texto para publicar ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: estaLogueado
                ? Column(
                    children: [
                      Row(
                        children: [
                          const Text('Categoría: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _categoriasPost.map((cat) {
                                  final isSelected = _selectedNewPostCategory == cat;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: ChoiceChip(
                                      label: Text(cat, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.grey.shade700)),
                                      selected: isSelected,
                                      selectedColor: const Color(0xFFE04E4E),
                                      backgroundColor: Colors.grey.shade200,
                                      onSelected: (_) => setState(() => _selectedNewPostCategory = cat),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Color(0xFFE04E4E),
                            child: Icon(Icons.person, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                        child: TextField(
                          controller: _textController,
                          focusNode: _textFocusNode,
                          maxLines: 3,
                          minLines: 1,
                          maxLength: 280,
                          decoration: InputDecoration(
                            hintText: _selectedNewPostCategory == 'Duda' ? 'Expresa tu duda a la comunidad...' :
                                      _selectedNewPostCategory == 'Empleo' ? 'Comparte una oportunidad laboral...' :
                                      _selectedNewPostCategory == 'Aviso' ? 'Escribe un aviso para todos...' :
                                      _selectedNewPostCategory == 'Proyecto' ? 'Cuéntanos sobre tu nuevo proyecto...' :
                                      'Aporta a la red universitaria...',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            counterStyle: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _isPosting
                          ? const SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send_rounded),
                              color: _color,
                              onPressed: _publicar,
                              tooltip: 'Publicar',
                            ),
                        ],
                      )
                    ],
                  )
                : GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ).then((_) => setState(() {})),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline, color: Colors.grey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Iniciá sesión para compartir tu experiencia',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ),
                          Text(
                            'Entrar →',
                            style: TextStyle(
                              color: _color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          if (estaLogueado && _myProfile != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  const Icon(Icons.filter_list, color: Color(0xFF1A2B4A), size: 20),
                  const SizedBox(width: 8),
                  const Text('Filtros:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A2B4A), fontSize: 13)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _currentFilter,
                          icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade800, fontWeight: FontWeight.w600),
                          onChanged: (val) {
                            if (val != null) setState(() => _currentFilter = val);
                          },
                          items: ['Todos', 'Mi Carrera', 'Mi Generación'].map((f) {
                            return DropdownMenuItem(value: f, child: Text(f, overflow: TextOverflow.ellipsis));
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _currentCategoryFilter,
                          icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade800, fontWeight: FontWeight.w600),
                          onChanged: (val) {
                            if (val != null) setState(() => _currentCategoryFilter = val);
                          },
                          items: _categorias.map((c) {
                            return DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis));
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),

          // ── Lista de posts ──
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPosts.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.museum_outlined, size: 80, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'Aún no hay publicaciones aquí. ¡Anímate a iniciar la conversación!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  if (estaLogueado) {
                                    FocusScope.of(context).requestFocus(_textFocusNode);
                                  } else {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())).then((_) => setState(() {}));
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE04E4E),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
                                ),
                                child: const Text('Crear Primera Publicación', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPosts,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredPosts.length,
                          itemBuilder: (context, index) {
                            final post = _filteredPosts[index];
                            final targetUserId = post['user_id'] as String;
                            final perfil = post['profiles'] as Map<String, dynamic>?;
                            final username = perfil?['nombre'] as String? ?? perfil?['username'] as String? ?? 'Visitante';
                            final carrera = perfil?['carrera'] as String? ?? '';
                            final esMentor = perfil?['mentoria_abierta'] == true;
                            final esMio = targetUserId == currentUserId;
                            final categoria = post['categoria'] as String? ?? 'General';
                            
                            final reactions = List<Map<String, dynamic>>.from(post['post_reactions'] ?? []);
                            final comentariosCount = (post['post_comments'] as List?)?.length ?? 0;
                            
                            Widget buildReactionButton(String icon, String type) {
                              final count = reactions.where((r) => r['reaction_type'] == type).length;
                              final iReacted = reactions.any((r) => r['reaction_type'] == type && r['user_id'] == currentUserId);
                              
                              return InkWell(
                                onTap: estaLogueado ? () => _reaccionar(post['id'], type) : null,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: iReacted ? _color.withValues(alpha: 0.1) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: iReacted ? _color : Colors.grey.shade300)
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(icon, style: const TextStyle(fontSize: 16)),
                                      if (count > 0) ...[
                                        const SizedBox(width: 4),
                                        Text('$count', style: TextStyle(color: iReacted ? _color : Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ]
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (perfil != null) {
                                              _mostrarPerfil(context, targetUserId, perfil, esMio, estaLogueado);
                                            }
                                          },
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundColor: _color.withValues(alpha: 0.1),
                                                child: Text(
                                                  username.isNotEmpty ? username[0].toUpperCase() : 'V',
                                                  style: const TextStyle(
                                                    color: _color,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              if (esMentor)
                                                Positioned(
                                                  bottom: -4,
                                                  right: -4,
                                                  child: Container(
                                                    padding: const EdgeInsets.all(2),
                                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                                    child: const Icon(Icons.school, size: 14, color: Color(0xFF1B9E8A)),
                                                  ),
                                                )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              if (perfil != null) {
                                                _mostrarPerfil(context, targetUserId, perfil, esMio, estaLogueado);
                                              }
                                            },
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  username,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color: Color(0xFF1A2B4A),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    if (carrera.isNotEmpty)
                                                      Text(
                                                        carrera,
                                                        style: TextStyle(
                                                          color: Colors.grey.shade500,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    if (carrera.isNotEmpty)
                                                      Text(' • ', style: TextStyle(color: Colors.grey.shade400)),
                                                    Text(
                                                      categoria,
                                                      style: const TextStyle(
                                                        color: Color(0xFFE04E4E),
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _formatFecha(post['created_at']),
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 12,
                                          ),
                                        ),
                                        if (esMio) ...[
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: const Text('Eliminar publicación'),
                                                content: const Text('¿Seguro que querés eliminarla?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text('Cancelar'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      _eliminar(post['id']);
                                                    },
                                                    child: const Text(
                                                      'Eliminar',
                                                      style: TextStyle(color: Colors.red),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.delete_outline,
                                              color: Colors.grey.shade400,
                                              size: 20,
                                            ),
                                          ),
                                        ] else if (estaLogueado) ...[
                                            const SizedBox(width: 4),
                                            PopupMenuButton<String>(
                                              padding: EdgeInsets.zero,
                                              icon: Icon(Icons.more_vert, color: Colors.grey.shade400, size: 20),
                                              onSelected: (value) async {
                                                if (value == 'report') {
                                                  _reportar(post['id']);
                                                } else if (value == 'block') {
                                                  final conf = await showDialog<bool>(
                                                    context: context,
                                                    builder: (_) => AlertDialog(
                                                      title: const Text('Bloquear usuario'),
                                                      content: Text('Dejarás de ver publicaciones de $username en el muro.'),
                                                      actions: [
                                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context, true),
                                                          child: const Text('Bloquear', style: TextStyle(color: Colors.red)),
                                                        ),
                                                      ]
                                                    )
                                                  );
                                                  if (conf == true) {
                                                    await SocialService().blockUser(targetUserId);
                                                    _loadPosts();
                                                  }
                                                }
                                              },
                                              itemBuilder: (_) => [
                                                const PopupMenuItem(value: 'report', child: Text('Reportar publicación')),
                                                const PopupMenuItem(value: 'block', child: Text('Bloquear usuario', style: TextStyle(color: Colors.red))),
                                              ],
                                            ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      post['contenido'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        height: 1.5,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        buildReactionButton('💡', 'inspiracion'),
                                        const SizedBox(width: 8),
                                        buildReactionButton('🏛️', 'recuerdo'),
                                        const SizedBox(width: 8),
                                        buildReactionButton('🎓', 'consejo'),
                                        const Spacer(),
                                        InkWell(
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor: Colors.transparent,
                                              builder: (_) => CommentsBottomSheet(postId: post['id'], muroService: _muroService),
                                            ).then((_) => _loadPosts());
                                          },
                                          borderRadius: BorderRadius.circular(16),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            child: Row(
                                              children: [
                                                Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey.shade600),
                                                if (comentariosCount > 0) ...[
                                                  const SizedBox(width: 6),
                                                  Text('$comentariosCount', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 13)),
                                                ]
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }


}
