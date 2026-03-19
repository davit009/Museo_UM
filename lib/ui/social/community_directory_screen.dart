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
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar directorio: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    
    setState(() {
      _filteredProfiles = _allProfiles.where((profile) {
        // Filter by Career (simulated ilike/contains logic for dropdown mapping)
        final pCarrera = (profile['carrera'] as String?)?.toLowerCase() ?? '';
        bool matchesCareer = _selectedCareer == 'Todas' || pCarrera.contains(_selectedCareer.toLowerCase());

        // Filter by text search (nombre or username)
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
      if (mounted) _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Búsqueda Textual
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => _applyFilters(),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre...',
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
          
          // Chips Horizontales (Filtros de Carrera)
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
          
          // Resultados
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B9E8A)))
              : _filteredProfiles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('No se encontraron perfiles.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredProfiles.length,
                    itemBuilder: (context, index) {
                      final profile = _filteredProfiles[index];
                      final name = profile['nombre'] as String? ?? profile['username'] as String? ?? 'Usuario';
                      final career = profile['carrera'] as String? ?? '';
                      final isMentor = profile['mentoria_abierta'] == true;
                      
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200)
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF1A2B4A).withValues(alpha: 0.1),
                            child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U', style: const TextStyle(color: Color(0xFF1A2B4A), fontWeight: FontWeight.bold)),
                          ),
                          title: Row(
                            children: [
                              Flexible(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis)),
                              if (isMentor) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.school, size: 14, color: Color(0xFF1B9E8A))
                              ]
                            ],
                          ),
                          subtitle: career.isNotEmpty 
                              ? Text(career, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)
                              : null,
                          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                          onTap: () => _abrirPerfilGlobal(profile['id'], profile),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
  }
}
