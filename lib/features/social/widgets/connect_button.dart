import 'package:flutter/material.dart';
import 'package:museo_app/features/social/services/social_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:museo_app/features/chat/screens/restricted_chat_screen.dart';

class ConnectButton extends StatelessWidget {
  final String targetUserId;
  final String targetUserName;
  final VoidCallback? onConnectPressed;
  final SocialService _socialService = SocialService();

  ConnectButton({
    super.key, 
    required this.targetUserId,
    required this.targetUserName,
    this.onConnectPressed,
  });

  Future<bool> _checkConnectionAllowed(String currentUserId, String targetId) async {
    final client = Supabase.instance.client;
    try {
      final currentUserRes = await client.from('profiles').select('es_egresado').eq('id', currentUserId).maybeSingle();
      final targetUserRes = await client.from('profiles').select('es_egresado, mentoria_abierta').eq('id', targetId).maybeSingle();
      
      if (currentUserRes == null || targetUserRes == null) return false;

      bool currentIsEgresado = currentUserRes['es_egresado'] == true;
      bool targetIsEgresado = targetUserRes['es_egresado'] == true;
      bool targetMentoriaAbierta = targetUserRes['mentoria_abierta'] == true;

      if (currentIsEgresado == targetIsEgresado) return true; // Alumno-Alumno o Ex-Ex
      if (!currentIsEgresado && targetIsEgresado && targetMentoriaAbierta) return true; // Alumno a Ex Alumno (Solo si da mentoría)

      return false; // Bloqueado (Ej. Ex a Alumno, o Alumno a Ex sin mentoría)
    } catch (_) {
      return false; 
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    if (currentUserId == null || currentUserId == targetUserId) {
      return const SizedBox.shrink(); 
    }

    return FutureBuilder<bool>(
      future: _checkConnectionAllowed(currentUserId, targetUserId),
      builder: (context, allowSnapshot) {
        if (!allowSnapshot.hasData) {
          return const SizedBox(
            width: 20, height: 20, 
            child: CircularProgressIndicator(strokeWidth: 2)
          );
        }
        
        final isAllowed = allowSnapshot.data!;

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
              if (!isAllowed) {
                return TextButton.icon(
                  icon: const Icon(Icons.lock_outline, size: 16),
                  label: const Text('No disponible', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Las reglas de privacidad bloquean esta conexión. Solo mentorías o mismo estatus.')),
                    );
                  }, 
                );
              }

              return TextButton.icon(
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('Conectar', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1B9E8A),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () async {
                  try {
                    await _socialService.sendConnectionRequest(targetUserId);
                    if (onConnectPressed != null) onConnectPressed!();
                  } catch (e) {
                    // Ignore error locally if already sent
                  }
                },
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
    );
  }
}

