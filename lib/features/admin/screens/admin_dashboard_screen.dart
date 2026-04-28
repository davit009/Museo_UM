import 'package:flutter/material.dart';
import 'package:museo_app/features/admin/services/admin_service.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final AdminService _adminService = AdminService();
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildPostsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _adminService.fetchAllPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay publicaciones en el sistema.'));
        }

        final posts = snapshot.data!;
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final profile = post['profiles'];
            final nombre = profile != null ? (profile['nombre'] ?? profile['username'] ?? 'Usuario') : 'Usuario Anónimo';
            final contenido = post['contenido'] ?? '';
            final date = DateTime.parse(post['created_at']).toLocal();

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(contenido),
                    const SizedBox(height: 8),
                    Text(DateFormat('dd/MM/yyyy hh:mm a').format(date), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('¿Eliminar Publicación?'),
                        content: const Text('Esta acción borrará el post definitivamente para todos.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true), 
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('ELIMINAR')
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await _adminService.deletePost(post['id']);
                      if (mounted) setState(() {}); 
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Publicación eliminada por administrador.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                      }
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReportsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _adminService.fetchReports(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay reportes pendientes.'));
        }

        final reports = snapshot.data!;
        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            final reporterProfile = report['profiles'];
            final post = report['posts'];
            final authorProfile = post != null ? post['profiles'] : null;
            
            final reporterName = reporterProfile != null ? (reporterProfile['nombre'] ?? reporterProfile['username'] ?? 'Usuario') : 'Anónimo';
            final authorName = authorProfile != null ? (authorProfile['nombre'] ?? authorProfile['username'] ?? 'Usuario') : 'Autor Desconocido';
            final content = post != null ? post['contenido'] : '[Publicación eliminada]';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ExpansionTile(
                leading: const Icon(Icons.report_problem, color: Colors.orange),
                title: Text('Reporte de: $reporterName', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Motivo: ${report['reason']}'),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey.shade50,
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Post original por $authorName:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('"$content"', style: const TextStyle(fontStyle: FontStyle.italic)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                              onPressed: () async {
                                await _adminService.dismissReport(report['id'].toString());
                                if (mounted) setState(() {});
                              },
                              icon: const Icon(Icons.check, color: Colors.green),
                              label: const Text('Ignorar', style: TextStyle(color: Colors.green)),
                            ),
                            if (post != null)
                              TextButton.icon(
                                onPressed: () async {
                                  await _adminService.deletePost(post['id']);
                                  await _adminService.dismissReport(report['id'].toString());
                                  if (mounted) setState(() {});
                                },
                                icon: const Icon(Icons.delete, color: Colors.red),
                                label: const Text('Borrar Post', style: TextStyle(color: Colors.red)),
                              ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfilesTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _adminService.fetchAllProfiles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay usuarios en la base de datos.'));
        }

        final allProfiles = snapshot.data!;
        final profiles = allProfiles.where((p) {
          final name = (p['nombre'] ?? p['username'] ?? '').toString().toLowerCase();
          final matricula = (p['matricula'] ?? '').toString().toLowerCase();
          return name.contains(_searchQuery.toLowerCase()) || matricula.contains(_searchQuery.toLowerCase());
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o matrícula...',
                  prefixIcon: const Icon(Icons.search, color: Colors.red),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            Expanded(
              child: profiles.isEmpty 
                ? const Center(child: Text('No se encontraron usuarios.'))
                : ListView.builder(
                    itemCount: profiles.length,
                    itemBuilder: (context, index) {
                      final p = profiles[index];
                      final nombre = p['nombre'] ?? p['username'] ?? 'Usuario';
                      final matricula = p['matricula'] ?? 'Sin matrícula';
                      final role = p['role'] ?? 'user';
                      final isEditor = role == 'editor';
                      final isSuperProtected = role == 'superadmin'; 

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSuperProtected ? Colors.amber.shade100 : (isEditor ? Colors.purple.shade100 : Colors.blue.shade100),
                            child: Icon(
                              isSuperProtected ? Icons.admin_panel_settings : (isEditor ? Icons.edit_note : Icons.person), 
                              color: isSuperProtected ? Colors.orange : (isEditor ? Colors.purple : Colors.blue)
                            ),
                          ),
                          title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Rol: ${role.toUpperCase()} • $matricula', style: const TextStyle(fontSize: 12)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isSuperProtected) ...[
                                IconButton(
                                  tooltip: isEditor ? 'Quitar Editor' : 'Hacer Editor',
                                  icon: Icon(isEditor ? Icons.person_remove : Icons.person_add_alt_1, color: isEditor ? Colors.orange : Colors.green),
                                  onPressed: () async {
                                    final newRole = isEditor ? 'user' : 'editor';
                                    await _adminService.updateUserRole(p['id'], newRole);
                                    if (mounted) setState(() {});
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usuario actualizado a $newRole')));
                                    }
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Banear Usuario',
                                  icon: const Icon(Icons.block, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('¿Banear Perfil?'),
                                        content: const Text('Esto ELIMINARÁ el perfil y todos sus datos definitivamente.'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true), 
                                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                                            child: const Text('BANEAR')
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await _adminService.deleteProfile(p['id']);
                                      if (mounted) setState(() {});
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Consola de Administrador'),
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(icon: Icon(Icons.comment), text: 'Muro Modera..'),
            Tab(icon: Icon(Icons.flag), text: 'Reportes'),
            Tab(icon: Icon(Icons.people), text: 'Auditoría Usuarios'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsTab(),
          _buildReportsTab(),
          _buildProfilesTab(),
        ],
      ),
    );
  }
}
