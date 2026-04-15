import 'package:flutter/material.dart';

class JubiladosScreen extends StatelessWidget {
  const JubiladosScreen({super.key});

  static const Color _color = Color(0xFF5B6FA0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: _color,
        title: const Text('Jubilados'),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: _jubiladosCondecorados.length,
        itemBuilder: (context, index) {
          final jubilado = _jubiladosCondecorados[index];
          return _JubiladoPhotoCard(
            name: jubilado['name']!,
            role: jubilado['role']!,
            imageUrl: jubilado['imageUrl']!,
            color: (index % 2 == 0) ? _color : const Color(0xFF1B9E8A),
          );
        },
      ),
    );
  }
}

final List<Map<String, String>> _jubiladosCondecorados = [
  {
    'name': 'Nombre 1',
    'role': 'Condecorado 1994',
    'imageUrl': 'https://picsum.photos/400/500?random=101',
  },
  {
    'name': 'Nombre 2',
    'role': 'Condecorado 1994',
    'imageUrl': 'https://picsum.photos/400/500?random=102',
  },
];

class _JubiladoPhotoCard extends StatelessWidget {
  final String name;
  final String role;
  final String imageUrl;
  final Color color;

  const _JubiladoPhotoCard({
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.person, size: 50, color: Colors.grey),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    role,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
