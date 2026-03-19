import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/profile_bottom_sheet.dart';

class CommunityDirectoryScreen extends StatefulWidget {
  const CommunityDirectoryScreen({super.key});

  @override
  State<CommunityDirectoryScreen> createState() => _CommunityDirectoryScreenState();
}

class _CommunityDirectoryScreenState extends State<CommunityDirectoryScreen> {
  final _client = Supabase.instance.client;
  final _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _allProfiles = [];
  List<Map<String, dynamic>> _filteredProfiles = [];
  Map<String, dynamic>? _myProfile;
  
  bool _isLoading = true;
  String _selectedCareer = 'Todas';

  final List<String> _careers = [
    'Todas',
    'Arquitectura',
    'Artes Visuales',
    'Comunicación y Medios',
    'Diseño de Comunicación Visual',
    'Ingeniería en Sistemas',
    'Medicina',
    'Nutrición',
    'Odontología',
    'Teología',
    'Derecho'
  ];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    try {
      final response = await _client.from('profiles').select().order('nombre', ascending: true);
      if (mounted) {
        setState(() {
          _allProfiles = List<Map<String, dynamic>>.from(response);
          final currentUserId = _client.auth.currentUser?.id;
          if (currentUserId != null) {
            final idx = _allProfiles.indexWhere((p) => p['id'] == currentUserId);
            if (idx != -1) _myProfile = _allProfiles[idx];
          }
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar red: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    
    setState(() {
      _filteredProfiles = _allProfiles.where((profile) {
        // Filter by Career
        final pCarrera = (profile['carrera'] as String?)?.toLowerCase() ?? '';
        bool matchesCareer = _selectedCareer == 'Todas' || pCarrera.contains(_selectedCareer.toLowerCase());

        // Filter by text search
        final rawName = profile['nombre'] as String? ?? '';
        final rawUsername = profile['username'] as String? ?? '';
        final matchesQuery = rawName.toLowerCase().contains(query) || rawUsername.toLowerCase().contains(query);

        return matchesCareer && matchesQuery;
      }).toList();
    });
  }

  void _abrirPerfilGlobal(String targetId, Map<String, dynamic> perfilData) {
    if (!mounted) return;
    ProfileBottomSheet.show(context, perfilData, onRefresh: () {
      if (mounted) _loadProfiles();
    });
  }

  Widget _buildProfileCard(Map<String, dynamic> profile) {
    final name = profile['nombre'] as String? ?? profile['username'] as String? ?? 'Usuario';
    final career = profile['carrera'] as String? ?? '';
    final gen = profile['generacion'] as String? ?? '';
    final isMentor = profile['mentoria_abierta'] == true;
    final esEgresado = profile['es_egresado'] == true;
    final puesto = profile['puesto_actual'] as String? ?? '';
    
    String subtitle = career;
    if (esEgresado && puesto.isNotEmpty) {
      subtitle = '$puesto\n$career';
    } else if (gen.isNotEmpty) {
      subtitle = '$career • $gen';
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), 
        side: BorderSide(color: Colors.grey.shade200)
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _abrirPerfilGlobal(profile['id'], profile),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                Container(
                  height: 48,
                  width: double.infinity,
                  color: const Color(0xFF1A2B4A).withOpacity(0.9),
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.all(8),
                  child: isMentor 
                      ? const Icon(Icons.school, color: Colors.amber, size: 16) 
                      : null,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 28, 8, 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600, height: 1.2),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        if (esEgresado)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B9E8A).withOpacity(0.1), 
                              borderRadius: BorderRadius.circular(8)
                            ),
                            child: const Text('Egresado', style: TextStyle(color: Color(0xFF1B9E8A), fontSize: 9, fontWeight: FontWeight.bold)),
                          )
                      ],
                    ),
                  ),
                )
              ],
            ),
            Positioned(
              top: 22,
              child: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 23,
                  backgroundColor: Colors.grey.shade100,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U', 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A2B4A))
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1B9E8A)));
    }

    final currentUserId = _client.auth.currentUser?.id;
    bool isFiltering = _searchController.text.isNotEmpty || _selectedCareer != 'Todas';
    
    List<Map<String, dynamic>> myGenProfiles = [];
    List<Map<String, dynamic>> exploreProfiles = [];
    
    if (!isFiltering && _myProfile != null) {
      final myGen = _myProfile!['generacion'] as String?;
      for (var p in _filteredProfiles) {
        if (p['id'] == currentUserId) continue; // omitir a mi mismo
        if (myGen != null && myGen.isNotEmpty && p['generacion'] == myGen) {
          myGenProfiles.add(p);
        } else {
          exploreProfiles.add(p);
        }
      }
    } else {
      exploreProfiles = _filteredProfiles.where((p) => p['id'] != currentUserId).toList();
    }

    return Column(
      children: [
        // Búsqueda
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => _applyFilters(),
            decoration: InputDecoration(
              hintText: 'Buscar compañeros o ex alumnos...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
          
        // Filtros Carrera
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _careers.length,
            itemBuilder: (context, index) {
              final career = _careers[index];
              final isSelected = _selectedCareer == career;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(career, style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  )),
                  selected: isSelected,
                  selectedColor: const Color(0xFF1A2B4A),
                  backgroundColor: Colors.grey.shade100,
                  checkmarkColor: Colors.white,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedCareer = career;
                      _applyFilters();
                    });
                  },
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
        
        // Red de Contactos
        Expanded(
          child: exploreProfiles.isEmpty && myGenProfiles.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('No se encontraron perfiles.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                  ],
                ),
              )
            : CustomScrollView(
                slivers: [
                  // --- Sección: Compañeros de Generación ---
                  if (myGenProfiles.isNotEmpty) ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            const Icon(Icons.history_edu, color: Color(0xFFE04E4E), size: 20),
                            const SizedBox(width: 8),
                            Text('Tu Generación (${_myProfile!['generacion']})', 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A2B4A))
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: myGenProfiles.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 140, // Ancho de la tarjeta horizontal
                                margin: const EdgeInsets.only(right: 12),
                                child: _buildProfileCard(myGenProfiles[index]),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    const SliverToBoxAdapter(child: Divider(height: 1)),
                  ],

                  // --- Sección: Explorar ---
                  if (exploreProfiles.isNotEmpty) ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          isFiltering ? 'Resultados de búsqueda' : 'Explorar Red',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A2B4A))
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.82, // Relación de aspecto para las tarjetas
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildProfileCard(exploreProfiles[index]),
                          childCount: exploreProfiles.length,
                        ),
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
        ),
      ],
    );
  }
}
