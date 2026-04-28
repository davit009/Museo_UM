import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:museo_app/features/social/services/muro_service.dart';
import 'package:museo_app/features/social/services/social_service.dart';
import 'package:museo_app/features/auth/screens/login_screen.dart';
import 'package:museo_app/features/social/widgets/connect_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:museo_app/features/social/screens/comments_bottom_sheet.dart';
import 'package:museo_app/features/admin/services/admin_service.dart';


class MuroScreen extends StatefulWidget {
  const MuroScreen({super.key});

  @override
  State<MuroScreen> createState() => _MuroScreenState();
}

class _MuroScreenState extends State<MuroScreen> {
  static const Color _color = Color(0xFF1A2B4A);

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
  String _myRole = 'user';
  final _adminService = AdminService();

  
  // Tagging
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _filteredFriends = [];
  bool _showSuggestions = false;
  final List<Map<String, dynamic>> _selectedTags = [];

  // Images
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _loadFriends();
    _textController.addListener(_onTextChanged);
  }

  Future<void> _loadFriends() async {
    final currentUserId = _muroService.currentUser?.id;
    if (currentUserId == null) return;
    
    // Obtenemos conexiones aceptadas
    SocialService().getAcceptedConnectionsStream().listen((connections) async {
      List<Map<String, dynamic>> friendsData = [];
      for (var conn in connections) {
        final friendId = conn['requester_id'] == currentUserId 
            ? conn['addressee_id'] 
            : conn['requester_id'];
        
        final profile = await SocialService().getProfile(friendId);
        if (profile != null) {
          friendsData.add(profile);
        }
      }
      if (mounted) {
        setState(() {
          _friends = friendsData;
        });
      }
    });
  }

  void _onTextChanged() {
    final text = _textController.text;
    final selection = _textController.selection;
    
    if (selection.baseOffset <= 0) {
      if (mounted) setState(() => _showSuggestions = false);
      return;
    }

    // Buscar si hay un @ antes del cursor
    final lastAt = text.substring(0, selection.baseOffset).lastIndexOf('@');
    if (lastAt != -1) {
      final query = text.substring(lastAt + 1, selection.baseOffset).toLowerCase();
      // Solo sugerir si no hay espacios después del @ hasta el cursor
      if (!query.contains(' ')) {
        setState(() {
          _filteredFriends = _friends.where((f) {
            final name = (f['nombre'] as String? ?? '').toLowerCase();
            final username = (f['username'] as String? ?? '').toLowerCase();
            return name.contains(query) || username.contains(query);
          }).toList();
          _showSuggestions = _filteredFriends.isNotEmpty;
        });
      } else {
        if (mounted) setState(() => _showSuggestions = false);
      }
    } else {
      if (mounted) setState(() => _showSuggestions = false);
    }
  }

  void _selectFriend(Map<String, dynamic> friend) {
    final text = _textController.text;
    final selection = _textController.selection;
    final lastAt = text.substring(0, selection.baseOffset).lastIndexOf('@');
    
    final name = friend['nombre'] as String? ?? friend['username'] as String? ?? 'Usuario';
    
    final newText = text.replaceRange(lastAt, selection.baseOffset, '@$name ');
    
    _textController.text = newText;
    _textController.selection = TextSelection.collapsed(offset: lastAt + name.length + 2);
    
    if (!_selectedTags.any((t) => t['id'] == friend['id'])) {
      _selectedTags.add(friend);
    }
    
    setState(() => _showSuggestions = false);
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
      final myRole = await _adminService.getCurrentUserRole();
      setState(() {
        _posts = posts;
        _myProfile = myProfile;
        _myRole = myRole;
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
    final userId = _muroService.currentUser!.id;

    // Actualización optimista: cambia el estado local al instante
    setState(() {
      final postIndex = _posts.indexWhere((p) => p['id'] == postId);
      if (postIndex == -1) return;
      final post = Map<String, dynamic>.from(_posts[postIndex]);
      final reactions = List<Map<String, dynamic>>.from(post['post_reactions'] ?? []);
      // Buscar reacción previa del usuario (cualquier tipo)
      final existingType = reactions
          .firstWhere((r) => r['user_id'] == userId, orElse: () => {})['reaction_type'];
      // Quitar cualquier reacción previa del usuario
      reactions.removeWhere((r) => r['user_id'] == userId);
      // Agregar la nueva solo si es distinta a la que ya tenía (si era igual, es toggle off)
      if (existingType != reactionType) {
        reactions.add({'reaction_type': reactionType, 'user_id': userId});
      }
      post['post_reactions'] = reactions;
      _posts[postIndex] = post;
    });

    try {
      await _muroService.toggleReaction(postId, reactionType);
    } catch (_) {}
  }

  Future<void> _publicar() async {
    final texto = _textController.text.trim();
    if (texto.isEmpty) return;

    setState(() => _isPosting = true);
    try {
      // Filtrar los IDs de los amigos que realmente están mencionados en el texto final
      final currentText = _textController.text;
      final taggedUserIds = _selectedTags
          .where((f) => currentText.contains('@${f['nombre']}') || currentText.contains('@${f['username']}'))
          .map((f) => f['id'] as String)
          .toList();

      await _muroService.createPost(
        texto, 
        categoria: _selectedNewPostCategory,
        taggedUserIds: taggedUserIds,
        imageFiles: _selectedImages,
      );

      // --- LOGICA DE NOTIFICACIONES PUSH PARA MENCIONADOS ---
      final miNombre = _myProfile?['nombre'] ?? _myProfile?['username'] ?? 'Un compañero';
      for (String targetUserId in taggedUserIds) {
        final res = await Supabase.instance.client
            .from('fcm_tokens')
            .select('token')
            .eq('user_id', targetUserId)
            .order('updated_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (res != null && res['token'] != null) {
          try {
            await Supabase.instance.client.functions.invoke(
              'notify-user',
              body: {
                'deviceToken': res['token'],
                'title': '¡Tienes una nueva mención!',
                'body': '$miNombre te ha mencionado en el Muro.',
              },
            );
          } catch (e) {
            print('Error al enviar notificacion push: $e');
          }
        }
      }
      // -----------------------------------------------------

      _textController.clear();
      _selectedTags.clear();
      _selectedImages.clear();
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
      // Usamos el servicio de admin si somos superadmin
      if (_myRole == 'superadmin') {
        await _adminService.deletePost(postId);
      } else {
        await _muroService.deletePost(postId);
      }
      await _loadPosts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Duda': return const Color(0xFFED6C02);
      case 'Aviso': return const Color(0xFF00838F);
      case 'Empleo': return const Color(0xFF2E7D32);
      case 'Proyecto': return const Color(0xFF6A1B9A);
      default: return const Color(0xFF1565C0);
    }
  }

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF1A2B4A), Color(0xFF1B9E8A), Color(0xFF1565C0),
      Color(0xFF6A1B9A), Color(0xFFED6C02), Color(0xFF2E7D32),
      Color(0xFFC62828), Color(0xFF00838F),
    ];
    if (name.isEmpty) return colors[0];
    return colors[name.codeUnitAt(0) % colors.length];
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
                backgroundColor: _color.withOpacity(0.15),
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
                      decoration: BoxDecoration(color: const Color(0xFF1B9E8A).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
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

  Widget _buildMentionSuggestions() {
    if (!_showSuggestions || _filteredFriends.isEmpty) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      margin: const EdgeInsets.only(top: 4, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _filteredFriends.length,
        itemBuilder: (context, index) {
          final friend = _filteredFriends[index];
          final name = friend['nombre'] as String? ?? friend['username'] as String? ?? 'Usuario';
          final carrera = friend['carrera'] as String? ?? '';

          return ListTile(
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: _color.withOpacity(0.1),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: carrera.isNotEmpty ? Text(carrera, style: const TextStyle(fontSize: 11)) : null,
            onTap: () => _selectFriend(friend),
          );
        },
      ),
    );
  }

  Widget _buildPostContent(String content, List<dynamic> mentions) {
    if (mentions.isEmpty) {
      return Text(
        content,
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
          color: Color(0xFF333333),
        ),
      );
    }

    final List<InlineSpan> spans = [];
    final words = content.split(' ');

    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      if (word.isEmpty) continue;

      bool isMention = false;
      Map<String, dynamic>? mentionedProfile;
      String? mentionedId;

      if (word.startsWith('@')) {
        final cleanName = word.substring(1).replaceAll(RegExp(r'[^\w\s]'), '');
        for (var mention in mentions) {
          final profile = mention['profiles'] as Map<String, dynamic>?;
          if (profile != null) {
            final mName = profile['nombre'] as String? ?? '';
            final mUser = profile['username'] as String? ?? '';
            if (mName == cleanName || mUser == cleanName) {
              isMention = true;
              mentionedProfile = profile;
              mentionedId = mention['user_id'] as String?;
              break;
            }
          }
        }
      }

      if (isMention && mentionedProfile != null && mentionedId != null) {
        spans.add(
          TextSpan(
            text: '$word ',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                _mostrarPerfil(
                  context,
                  mentionedId!,
                  mentionedProfile!,
                  mentionedId == _muroService.currentUser?.id,
                  _muroService.currentUser != null,
                );
              },
          ),
        );
      } else {
        spans.add(TextSpan(text: '$word '));
      }
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
          color: Color(0xFF333333),
        ),
        children: spans,
      ),
    );
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Puedes subir un máximo de 3 imágenes.')));
      return;
    }
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 70, // Reducir calidad para optimizar subida
      );
      if (images.isNotEmpty) {
        setState(() {
          for (var img in images) {
            if (_selectedImages.length < 3) {
              _selectedImages.add(File(img.path));
            }
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al seleccionar imagen: $e')));
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Widget _buildSelectedImagesPreview() {
    if (_selectedImages.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 70,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(_selectedImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: -4,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.white, size: 20),
                  onPressed: () => _removeImage(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostImages(List<dynamic>? imageUrls) {
    if (imageUrls == null || imageUrls.isEmpty) return const SizedBox.shrink();
    
    final urls = List<String>.from(imageUrls);
    
    if (urls.length == 1) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(urls[0], fit: BoxFit.cover),
      );
    }
    
    return Container(
      height: 180,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: EdgeInsets.only(right: index == urls.length - 1 ? 0 : 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(urls[index], fit: BoxFit.cover),
          );
        },
      ),
    );
  }

  bool _isUserAdmin(Map<String, dynamic>? perfil) {
    if (perfil == null) return false;
    final role = (perfil['role'] ?? '').toString().toLowerCase();
    final isAdmin = perfil['is_admin'] == true;
    return isAdmin || role == 'admin' || role == 'superadmin' || role == 'editor' || role == 'moderator';
  }

  bool _isUserSuperAdmin(Map<String, dynamic>? perfil) {
    if (perfil == null) return false;
    final role = (perfil['role'] ?? '').toString().toLowerCase();
    final isAdmin = perfil['is_admin'] == true;
    return isAdmin || role == 'admin' || role == 'superadmin';
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _muroService.currentUser?.id;
    final estaLogueado = currentUserId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: _color,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('COMUNIDAD UM', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            Text('Conecta con el pasado y presente', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _loadPosts,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Caja de texto para publicar ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: estaLogueado
                ? Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFF1A2B4A),
                            child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              focusNode: _textFocusNode,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: '¿Qué estás pensando?',
                                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _buildMentionSuggestions(),
                      _buildSelectedImagesPreview(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Botones de acción
                          IconButton(
                            icon: const Icon(Icons.image_outlined, size: 22),
                            color: _color,
                            onPressed: _pickImages,
                            visualDensity: VisualDensity.compact,
                          ),
                          const SizedBox(width: 4),
                          // Categoría Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedNewPostCategory,
                                isDense: true,
                                style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w600),
                                items: _categoriasPost.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedNewPostCategory = val);
                                },
                              ),
                            ),
                          ),
                          const Spacer(),
                          _isPosting
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                              : ElevatedButton(
                                  onPressed: _publicar,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _color,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  child: const Text('Publicar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                        ],
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFFB8973A)),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Únete a la conversación universitaria.',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())).then((_) => setState(() {})),
                          child: const Text('Iniciar Sesión', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
          ),

          // ── Filtros ──
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ...['Todos', 'Mi Carrera', 'Mi Generación'].map((f) {
                    if (!estaLogueado && f != 'Todos') return const SizedBox.shrink();
                    final isSelected = _currentFilter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: isSelected,
                        onSelected: (val) => setState(() => _currentFilter = f),
                        selectedColor: _color,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: Colors.white,
                        elevation: 0,
                        pressElevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300)),
                      ),
                    );
                  }),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(height: 20, child: VerticalDivider(width: 1, color: Colors.grey)),
                  ),
                  ..._categorias.map((c) {
                    final isSelected = _currentCategoryFilter == c;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c),
                        selected: isSelected,
                        onSelected: (val) => setState(() => _currentCategoryFilter = c),
                        selectedColor: _categoryColor(c).withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: isSelected ? _categoryColor(c) : Colors.black87,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? _categoryColor(c) : Colors.grey.shade300)),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ── Lista de posts ──
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadPosts,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: _filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = _filteredPosts[index];
                        final targetUserId = post['user_id'] as String;
                        final perfil = post['profiles'] as Map<String, dynamic>?;
                        final username = perfil?['nombre'] as String? ?? perfil?['username'] as String? ?? 'Anónimo';
                        final carrera = perfil?['carrera'] as String? ?? '';
                        final esMio = targetUserId == currentUserId;
                        final categoria = post['categoria'] as String? ?? 'General';
                        final esAdminPost = _isUserAdmin(perfil);
                        final esSuperAdminPost = _isUserSuperAdmin(perfil);
                        
                        final reactions = List<Map<String, dynamic>>.from(post['post_reactions'] ?? []);
                        final comentariosCount = (post['post_comments'] as List?)?.length ?? 0;
                        
                        Widget buildReactionButton(String icon, String type) {
                          final count = reactions.where((r) => r['reaction_type'] == type).length;
                          final iReacted = reactions.any((r) => r['reaction_type'] == type && r['user_id'] == currentUserId);

                          return InkWell(
                            onTap: estaLogueado ? () => _reaccionar(post['id'], type) : null,
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: iReacted ? _color.withOpacity(0.1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Text(icon, style: const TextStyle(fontSize: 16)),
                                  if (count > 0) ...[
                                    const SizedBox(width: 4),
                                    Text('$count', style: TextStyle(color: iReacted ? _color : Colors.grey.shade600, fontSize: 12, fontWeight: iReacted ? FontWeight.bold : FontWeight.normal)),
                                  ]
                                ],
                              ),
                            ),
                          );
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: esAdminPost 
                              ? Border.all(color: esSuperAdminPost ? const Color(0xFFB8973A).withOpacity(0.5) : _color.withOpacity(0.3), width: 1.5)
                              : Border.all(color: Colors.grey.withOpacity(0.1)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Announcement Header if Admin + Aviso
                              if (esAdminPost && categoria == 'Aviso')
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: esSuperAdminPost 
                                        ? [const Color(0xFFB8973A), const Color(0xFFD4AF5A)]
                                        : [_color, _color.withOpacity(0.8)],
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.campaign_rounded, color: Colors.white, size: 16),
                                      SizedBox(width: 8),
                                      Text('COMUNICADO OFICIAL', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                                    ],
                                  ),
                                ),
                              
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => perfil != null ? _mostrarPerfil(context, targetUserId, perfil, esMio, estaLogueado) : null,
                                          child: CircleAvatar(
                                            radius: 20,
                                            backgroundColor: esAdminPost ? (esSuperAdminPost ? const Color(0xFFB8973A) : _color) : _avatarColor(username),
                                            child: Text(
                                              username.isNotEmpty ? username[0].toUpperCase() : 'U',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                                  if (esAdminPost) ...[
                                                    const SizedBox(width: 4),
                                                    Icon(Icons.verified_rounded, size: 16, color: esSuperAdminPost ? const Color(0xFFB8973A) : _color),
                                                  ],
                                                ],
                                              ),
                                              Text(
                                                '${carrera.isNotEmpty ? "$carrera • " : ""}${_formatFecha(post['created_at'])}',
                                                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (esMio || _myRole == 'superadmin')
                                          IconButton(
                                            icon: const Icon(Icons.more_horiz_rounded, size: 20),
                                            onPressed: () {
                                              showModalBottomSheet(
                                                context: context,
                                                builder: (_) => Container(
                                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      ListTile(
                                                        leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                                                        title: const Text('Eliminar publicación', style: TextStyle(color: Colors.red)),
                                                        onTap: () {
                                                          Navigator.pop(context);
                                                          _eliminar(post['id']);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        else if (estaLogueado)
                                          IconButton(
                                            icon: const Icon(Icons.flag_outlined, size: 20),
                                            onPressed: () => _reportar(post['id']),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    _buildPostContent(post['contenido'] ?? '', post['post_mentions'] ?? []),
                                    _buildPostImages(post['image_urls']),
                                  ],
                                ),
                              ),
                              
                              // Category and Footer
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                child: Row(
                                  children: [
                                    buildReactionButton('👍', 'inspiracion'),
                                    const SizedBox(width: 8),
                                    buildReactionButton('❤️', 'recuerdo'),
                                    const SizedBox(width: 8),
                                    buildReactionButton('🎉', 'consejo'),
                                    const Spacer(),
                                    TextButton.icon(
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (_) => CommentsBottomSheet(postId: post['id'], muroService: _muroService),
                                        ).then((_) => _loadPosts());
                                      },
                                      icon: Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Colors.grey.shade600),
                                      label: Text(
                                        comentariosCount > 0 ? '$comentariosCount' : 'Comentar',
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        backgroundColor: Colors.grey.shade100,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
