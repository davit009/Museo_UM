import 'package:flutter/material.dart';
import '../../services/social_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../chat/restricted_chat_screen.dart';

class ConnectButton extends StatelessWidget {
  final String targetUserId;
  final String targetUserName;
  final SocialService _socialService = SocialService();

  ConnectButton({
    super.key, 
    required this.targetUserId,
    required this.targetUserName,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    if (currentUserId == null || currentUserId == targetUserId) {
      return const SizedBox.shrink(); 
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _socialService.connectionStatusStream(targetUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            width: 20, height: 20, 
            child: CircularProgressIndicator(strokeWidth: 2)
          );
        }
        
        final connections = snapshot.data!;
        
        if (connections.isEmpty) {
          // No están conectados
          return TextButton.icon(
            icon: const Icon(Icons.person_add, size: 16),
            label: const Text('Conectar', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1B9E8A),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => _socialService.sendConnectionRequest(targetUserId),
          );
        }

        final connection = connections.first;
        final status = connection['status'];
        final isRequester = connection['requester_id'] == currentUserId;

        if (status == 'pending') {
          if (isRequester) {
            return TextButton.icon(
              icon: const Icon(Icons.access_time, size: 16),
              label: const Text('Pendiente', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: null, 
            );
          } else {
            // Recibió solicitud
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  onPressed: () => _socialService.updateConnectionStatus(connection['id'], 'accepted'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                  onPressed: () => _socialService.updateConnectionStatus(connection['id'], 'rejected'),
                ),
              ],
            );
          }
        } else if (status == 'accepted') {
          return TextButton.icon(
            icon: const Icon(Icons.message, size: 16),
            label: const Text('Mensaje', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1A2B4A),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (_) => RestrictedChatScreen(
                    targetUserId: targetUserId,
                    targetUserName: targetUserName,
                  )
                )
              );
            },
          );
        }

        return const SizedBox.shrink(); // 'rejected'
      },
    );
  }
}
