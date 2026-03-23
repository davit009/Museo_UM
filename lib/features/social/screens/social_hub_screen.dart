import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:museo_app/features/social/services/social_service.dart';
import 'package:museo_app/features/chat/screens/restricted_chat_screen.dart';
import 'package:museo_app/features/social/widgets/profile_bottom_sheet.dart';
import 'package:museo_app/features/social/screens/community_directory_screen.dart';

class SocialHubScreen extends StatefulWidget {
  const SocialHubScreen({super.key});

  @override
  State<SocialHubScreen> createState() => _SocialHubScreenState();
}

class _SocialHubScreenState extends State<SocialHubScreen> with SingleTickerProviderStateMixin {
  final _socialService = SocialService();
  final String _currentUserId = Supabase.instance.client.auth.currentUser!.id;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildMensajesTab() {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _tabController.animateTo(2), // Ir a Buscar
        backgroundColor: const Color(0xFF1B9E8A),
        child: const Icon(Icons.person_search, color: Colors.white),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _socialService.getAcceptedConnectionsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final connections = snapshot.data!;
          if (connections.isEmpty) {
            return const Center(child: Text('No tienes conexiones aún. ¡Busca personas!'));
          }

          return ListView.builder(
            itemCount: connections.length,
            itemBuilder: (context, index) {
              final conn = connections[index];
              final otherUserId = conn['requester_id'] == _currentUserId 
                  ? conn['addressee_id'] 
                  : conn['requester_id'];

              return FutureBuilder<Map<String, dynamic>?>(
                future: _socialService.getProfile(otherUserId),
                builder: (context, profileSnap) {
                  if (!profileSnap.hasData) return const SizedBox.shrink();
                  
                  final profile = profileSnap.data!;
                  final nombre = (profile['nombre'] ?? profile['username'] ?? 'Usuario').toString();
                  final carrera = (profile['carrera'] ?? '').toString();

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF1A2B4A).withValues(alpha: 0.1),
                        child: Text(nombre.isNotEmpty ? nombre[0].toUpperCase() : 'V', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A2B4A))),
                      ),
                      title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(carrera, maxLines: 1),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RestrictedChatScreen(
                              targetUserId: otherUserId,
                              targetUserName: nombre,
                            )
                          )
                        );
                      },
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

  Widget _buildAmigosTab() {
    return Container(
      color: const Color(0xFFF0F4F8),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _socialService.getAcceptedConnectionsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final connections = snapshot.data!;
          if (connections.isEmpty) {
            return const Center(child: Text('Aún no tienes amigos en la red.'));
          }

          return ListView.builder(
            itemCount: connections.length,
            itemBuilder: (context, index) {
              final conn = connections[index];
              final otherUserId = conn['requester_id'] == _currentUserId 
                  ? conn['addressee_id'] 
                  : conn['requester_id'];

              return FutureBuilder<Map<String, dynamic>?>(
                future: _socialService.getProfile(otherUserId),
                builder: (context, profileSnap) {
                  if (!profileSnap.hasData) return const SizedBox.shrink();
                  
                  final profile = profileSnap.data!;
                  final nombre = (profile['nombre'] ?? profile['username'] ?? 'Usuario').toString();
                  final carrera = (profile['carrera'] ?? '').toString();

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF1B9E8A).withValues(alpha: 0.1),
                        child: Text(nombre.isNotEmpty ? nombre[0].toUpperCase() : 'V', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B9E8A))),
                      ),
                      title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(carrera, maxLines: 1),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.person, color: Colors.blue),
                            onPressed: () => ProfileBottomSheet.show(context, profile),
                          ),
                          IconButton(
                            icon: const Icon(Icons.person_remove, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('¿Eliminar amig@?'),
                                  content: Text('Se eliminará tu conexión con $nombre.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true), 
                                      child: const Text('Eliminar', style: TextStyle(color: Colors.red))
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await _socialService.removeConnection(otherUserId);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Amistad eliminada.'), backgroundColor: Colors.red));
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () => ProfileBottomSheet.show(context, profile),
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

  Widget _buildSolicitudesTab() {
    return Container(
      color: const Color(0xFFF0F4F8),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _socialService.getPendingRequestsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final requests = snapshot.data!;
          if (requests.isEmpty) {
            return const Center(child: Text('No tienes solicitudes pendientes.'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final requesterId = req['requester_id'];

              return FutureBuilder<Map<String, dynamic>?>(
                future: _socialService.getProfile(requesterId),
                builder: (context, profileSnap) {
                  if (!profileSnap.hasData) return const SizedBox.shrink();
                  
                  final profile = profileSnap.data!;
                  final nombre = (profile['nombre'] ?? profile['username'] ?? 'Usuario').toString();

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF1B9E8A).withValues(alpha: 0.2),
                        child: const Icon(Icons.person, color: Color(0xFF1B9E8A)),
                      ),
                      title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Quiere conectar contigo'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () => _socialService.updateConnectionStatus(req['id'], 'accepted'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => _socialService.updateConnectionStatus(req['id'], 'rejected'),
                          ),
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

  Widget _buildBuscarTab() {
    return Container(
      color: const Color(0xFFF0F4F8),
      child: const CommunityDirectoryScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Conexiones'),
        backgroundColor: const Color(0xFF1A2B4A),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: const Color(0xFF1B9E8A),
          tabs: const [
            Tab(icon: Icon(Icons.message), text: 'Mensajes'),
            Tab(icon: Icon(Icons.group), text: 'Amigos'),
            Tab(icon: Icon(Icons.person_add), text: 'Solicitudes'),
            Tab(icon: Icon(Icons.search), text: 'Buscar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMensajesTab(),
          _buildAmigosTab(),
          _buildSolicitudesTab(),
          _buildBuscarTab(),
        ],
      ),
    );
  }
}

