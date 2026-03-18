import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/social_service.dart';
import '../chat/restricted_chat_screen.dart';
import '../widgets/connect_button.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
    return const _SearchTabContent();
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
            Tab(icon: Icon(Icons.person_add), text: 'Solicitudes'),
            Tab(icon: Icon(Icons.search), text: 'Buscar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMensajesTab(),
          _buildSolicitudesTab(),
          _buildBuscarTab(),
        ],
      ),
    );
  }
}

class _SearchTabContent extends StatefulWidget {
  const _SearchTabContent();

  @override
  State<_SearchTabContent> createState() => _SearchTabContentState();
}

class _SearchTabContentState extends State<_SearchTabContent> {
  final _socialService = SocialService();
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;

  void _search([String? _]) async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isLoading = true);
    final results = await _socialService.searchProfiles(query);
    if (mounted) {
      setState(() {
        _results = results;
        _isLoading = false;
      });
    }
  }

  void _mostrarPerfilBottomSheet(BuildContext context, Map<String, dynamic> perfil) {
    final targetUserId = perfil['id'];
    final nombre = perfil['nombre'] ?? perfil['username'] ?? 'Usuario';
    final matricula = perfil['matricula'] ?? 'Sin matrícula';
    final carrera = perfil['carrera'] ?? 'Sin carrera detallada';

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
              CircleAvatar(radius: 40, backgroundColor: const Color(0xFF1A2B4A).withValues(alpha: 0.1), child: const Icon(Icons.person, size: 40, color: Color(0xFF1A2B4A))),
              const SizedBox(height: 16),
              Text(nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(matricula, style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                child: Text(carrera, style: TextStyle(color: Colors.grey.shade700)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ConnectButton(targetUserId: targetUserId, targetUserName: nombre),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F4F8),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o matrícula...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
            onSubmitted: (value) => _search(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _results.isEmpty 
                  ? const Center(child: Text('Sin resultados', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final p = _results[index];
                        final nombre = (p['nombre'] ?? p['username'] ?? 'Usuario').toString();
                        final matricula = (p['matricula'] ?? '').toString();
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF1A2B4A).withValues(alpha: 0.1),
                              child: Text(nombre.isNotEmpty ? nombre[0].toUpperCase() : 'V', style: const TextStyle(color: Color(0xFF1A2B4A))),
                            ),
                            title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(matricula),
                            onTap: () => _mostrarPerfilBottomSheet(context, p),
                            trailing: ConnectButton(targetUserId: p['id'].toString(), targetUserName: nombre),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
