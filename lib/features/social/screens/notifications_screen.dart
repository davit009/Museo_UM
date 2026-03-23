import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _client = Supabase.instance.client;

  String get _currentUserId => _client.auth.currentUser!.id;

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm', 'es_MX').format(dt);
    } catch (_) {
      return '';
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _client
          .from('in_app_notifications')
          .update({'leido': true})
          .eq('id', notificationId);
    } catch (_) {}
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'request_received':
        return Icons.person_add;
      case 'request_accepted':
        return Icons.how_to_reg;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'like':
        return Colors.red;
      case 'request_received':
        return const Color(0xFF1B9E8A);
      case 'request_accepted':
        return const Color(0xFF1B6EA8);
      default:
        return const Color(0xFF1A2B4A);
    }
  }

  String _getTextForType(String type, String actorName) {
    switch (type) {
      case 'like':
        return '$actorName reaccionó a tu publicación.';
      case 'request_received':
        return '$actorName te ha enviado una solicitud de conexión.';
      case 'request_accepted':
        return '$actorName aceptó tu solicitud de conexión.';
      default:
        return 'Tienes una notificación de $actorName.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notificaciones', style: TextStyle(color: Color(0xFF1A2B4A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A2B4A)),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _client
            .from('in_app_notifications')
            .stream(primaryKey: ['id'])
            .eq('user_id', _currentUserId)
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF1A2B4A)));
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error al cargar notificaciones.', style: TextStyle(color: Colors.red.shade400)));
            }

            final data = snapshot.data ?? [];

            if (data.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('No tienes notificaciones.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final notif = data[index];
                final isLeido = notif['leido'] == true;
                final tipo = notif['tipo'] as String;
                final actorId = notif['actor_id'] as String;

                // Load actor profile lazily to display name
                return FutureBuilder<Map<String, dynamic>>(
                  future: _client.from('profiles').select('nombre, username, avatar_url').eq('id', actorId).single(),
                  builder: (context, profileSnapshot) {
                    if (!profileSnapshot.hasData) return const SizedBox.shrink();
                    final profile = profileSnapshot.data!;
                    final actorName = profile['nombre'] as String? ?? profile['username'] as String? ?? 'Alguien';
                    
                    return InkWell(
                      onTap: () {
                         if (!isLeido) _markAsRead(notif['id']);
                         // Podrías navegar al post si post_id != null
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        color: isLeido ? Colors.white : const Color(0xFF1A2B4A).withValues(alpha: 0.05),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: _getColorForType(tipo).withValues(alpha: 0.1),
                              child: Icon(_getIconForType(tipo), color: _getColorForType(tipo), size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getTextForType(tipo, actorName),
                                    style: TextStyle(
                                      fontWeight: isLeido ? FontWeight.normal : FontWeight.w600,
                                      color: const Color(0xFF1A2B4A),
                                      fontSize: 15
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(notif['created_at']),
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLeido)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1B9E8A),
                                  shape: BoxShape.circle,
                                ),
                              )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
        },
      ),
    );
  }
}
