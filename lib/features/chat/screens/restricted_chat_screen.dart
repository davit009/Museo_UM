import 'package:flutter/material.dart';
import 'package:museo_app/features/social/services/social_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:museo_app/core/utils/profanity_filter.dart';
import 'package:museo_app/features/social/widgets/profile_bottom_sheet.dart';

class RestrictedChatScreen extends StatefulWidget {
  final String targetUserId;
  final String targetUserName;

  const RestrictedChatScreen({
    super.key,
    required this.targetUserId,
    required this.targetUserName,
  });

  @override
  State<RestrictedChatScreen> createState() => _RestrictedChatScreenState();
}

class _RestrictedChatScreenState extends State<RestrictedChatScreen> {
  final _socialService = SocialService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final String _currentUserId = Supabase.instance.client.auth.currentUser!.id;
  bool _reading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _markAsReadIfNeeded(List<Map<String, dynamic>> messages) async {
    if (_reading) return;
    final unread = messages.where((m) => m['sender_id'] == widget.targetUserId && m['leido'] != true).toList();
    if (unread.isNotEmpty) {
      _reading = true;
      try {
        await _socialService.markMessagesAsRead(widget.targetUserId);
      } finally {
        _reading = false;
      }
    }
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
  
  String _getDateSeparatorText(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) return 'Hoy';
    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(date, yesterday)) return 'Ayer';
    return DateFormat('d MMM yyyy').format(date);
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    if (ProfanityFilter.hasProfanity(text)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El mensaje contiene lenguaje no permitido en el museo.'),
            backgroundColor: Colors.red,
          )
        );
      }
      return;
    }
    
    _messageController.clear();
    try {
      await _socialService.sendMessage(widget.targetUserId, text);
      _scrollToBottom();

      // --- LOGICA DE NOTIFICACIONES PUSH PARA CHAT ---
      final res = await Supabase.instance.client
          .from('fcm_tokens')
          .select('token')
          .eq('user_id', widget.targetUserId)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (res != null && res['token'] != null) {
        try {
          final myProfile = await _socialService.getProfile(_currentUserId);
          final myName = myProfile?['nombre'] ?? myProfile?['username'] ?? 'Un compañero';

          await Supabase.instance.client.functions.invoke(
            'notify-user',
            body: {
              'deviceToken': res['token'],
              'title': '¡Nuevo Mensaje Privado!',
              'body': '$myName te ha escrito en el Chat.',
            },
          );
        } catch (e) {
          print('Error al enviar push de chat: $e');
        }
      }
      // ---------------------------------------------

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar el mensaje.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _showTargetProfile() async {
    try {
      final profile = await _socialService.getProfile(widget.targetUserId);
      if (profile != null && mounted) {
        ProfileBottomSheet.show(context, profile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo cargar el perfil.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: InkWell(
          onTap: _showTargetProfile,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white24,
                child: Text(
                  widget.targetUserName.isNotEmpty ? widget.targetUserName[0].toUpperCase() : 'V', 
                  style: const TextStyle(color: Colors.white, fontSize: 14)
                ),
              ),
              const SizedBox(width: 10),
              Text(widget.targetUserName, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF1A2B4A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Banner Cero Fricción
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.amber.shade100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Este chat es para coordinarse inicialmente. Si desean conversar más, intercámbiense datos externos (LinkedIn, WhatsApp).',
                    style: TextStyle(fontSize: 13, color: Colors.brown.shade800),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _socialService.getMessagesStream(widget.targetUserId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                
                // Marcar como leído sigilosamente
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _markAsReadIfNeeded(messages);
                });

                // Reversing because we will use reverse: true in ListView
                final reversedMessages = messages.reversed.toList();

                if (reversedMessages.isEmpty) {
                  return const Center(
                    child: Text('Aún no hay mensajes. ¡Escribe para saludar!',
                      style: TextStyle(color: Colors.grey)
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true, // Empieza desde abajo
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: reversedMessages.length,
                  itemBuilder: (context, index) {
                    final msg = reversedMessages[index];
                    final isMe = msg['sender_id'] == _currentUserId;
                    final date = DateTime.parse(msg['created_at']).toLocal();
                    final isRead = msg['leido'] == true;

                    bool showDateSeparator = false;
                    if (index == reversedMessages.length - 1) {
                      showDateSeparator = true;
                    } else {
                      final nextMsg = reversedMessages[index + 1]; // chronological older
                      final nextDate = DateTime.parse(nextMsg['created_at']).toLocal();
                      if (!_isSameDay(date, nextDate)) {
                        showDateSeparator = true;
                      }
                    }

                    final separator = showDateSeparator ? Container(
                        margin: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                            child: Text(_getDateSeparatorText(date), style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold))
                          ),
                        )
                    ) : const SizedBox.shrink();

                    return Column(
                      children: [
                        separator,
                        Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe ? const Color(0xFF1B9E8A) : Colors.grey.shade200,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                                bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg['content'],
                                  style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat('hh:mm a').format(date),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isMe ? Colors.white70 : Colors.black54,
                                      ),
                                    ),
                                    if (isMe) ...[
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.done_all, 
                                        size: 14, 
                                        color: isRead ? Colors.blue.shade200 : Colors.white60
                                      )
                                    ]
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Caja de texto
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLength: 250,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        counterText: '', // Ocultar el counter si se desea, se limita con maxLength
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF1A2B4A),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
