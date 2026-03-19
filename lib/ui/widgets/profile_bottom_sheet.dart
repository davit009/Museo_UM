import 'package:flutter/material.dart';
import '../../services/social_service.dart';
import 'connect_button.dart';

class ProfileBottomSheet {
  static void show(BuildContext context, Map<String, dynamic> perfil, {VoidCallback? onRefresh}) {
    final targetUserId = perfil['id'] ?? '';
    final nombre = perfil['nombre'] ?? perfil['username'] ?? 'Usuario';
    final matricula = perfil['matricula'] ?? 'Sin matrícula';
    final carrera = perfil['carrera'] ?? 'Sin carrera detallada';
    final biografia = perfil['biografia'] ?? '';
    final _socialService = SocialService();

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
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 40, 
                backgroundColor: const Color(0xFF1A2B4A).withValues(alpha: 0.1), 
                child: Text(nombre.isNotEmpty ? nombre[0].toUpperCase() : 'V', style: const TextStyle(fontSize: 32, color: Color(0xFF1A2B4A)))
              ),
              const SizedBox(height: 16),
              Text(nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(matricula, style: TextStyle(color: Colors.grey.shade600)),
              
              if (biografia.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200)
                  ),
                  child: Text(
                    '"$biografia"',
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.brown.shade800),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                child: Text(carrera, style: TextStyle(color: Colors.grey.shade700)),
              ),
              const SizedBox(height: 24),
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
                  await _socialService.blockUser(targetUserId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Has bloqueado a $nombre. Sus datos han sido ocultados.')),
                    );
                    if (onRefresh != null) onRefresh();
                  }
                },
                icon: const Icon(Icons.block, color: Colors.red),
                label: const Text('Bloquear Usuario', style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
