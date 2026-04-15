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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_color, const Color(0xFF3D4A6F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.groups, color: Colors.white, size: 40),
                      SizedBox(width: 12),
                      Text(
                        'Jubilados',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'En esta sección se presentan los jubilados de la Universidad de Montemorelos, reconociendo su trayectoria y servicio.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                  topLabel: jubilado['topLabel']!,
                  bottomLabel: jubilado['bottomLabel']!,
                  imageFile: jubilado['imageFile']!,
                  color: (index % 2 == 0) ? _color : const Color(0xFF1B9E8A),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

const List<String> _jubiladosBaseUrls = [
  'http://64.23.168.72/media/Jubilados',
  'http://64.23.168.72/Jubilados',
  'https://64.23.168.72/media/Jubilados',
  'https://64.23.168.72/Jubilados',
];

const List<String> _jubiladosImageFiles = [
  'WhatsApp Image 2026-04-07 at 17.02.51 (1).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.56 (3).jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.38 (3).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.51.jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.56 (4).jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.38 (4).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.52 (1).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.56.jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.38 (5).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.52 (2).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.57 (1).jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.38.jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.52 (3).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.57 (2).jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.39 (1).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.52 (4).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.57 (3).jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.39 (2).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.52.jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.57 (4).jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.39 (3).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.53 (1).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.57.jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.39 (4).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.53 (2).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.58.jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.39 (5).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.53.jpeg',
  'WhatsApp Image 2026-04-07 at 17.04.30.jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.39 (6).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.55 (1).jpeg',
  'WhatsApp Image 2026-04-07 at 17.04.31.jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.39 (7).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.55 (2).jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.37 (1).jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.39 (8).jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.55.jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.37.jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.39.jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.56 (1).jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.38 (1).jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.40.jpeg',
  'WhatsApp Image 2026-04-07 at 17.02.56 (2).jpeg',
  'WhatsApp Image 2026-04-07 at 17.05.38 (2).jpeg',
];

final List<Map<String, String>> _jubiladosCondecorados = _jubiladosImageFiles
    .asMap()
    .entries
    .map(
      (entry) => {
        'topLabel': 'Jubilados',
        'bottomLabel': 'Memorias del museo',
        'imageFile': entry.value,
      },
    )
    .toList();

class _JubiladoPhotoCard extends StatefulWidget {
  final String topLabel;
  final String bottomLabel;
  final String imageFile;
  final Color color;

  const _JubiladoPhotoCard({
    required this.topLabel,
    required this.bottomLabel,
    required this.imageFile,
    required this.color,
  });

  @override
  State<_JubiladoPhotoCard> createState() => _JubiladoPhotoCardState();
}

class _JubiladoPhotoCardState extends State<_JubiladoPhotoCard> {
  int _baseUrlIndex = 0;

  String get _currentImageUrl {
    final encodedFile = Uri.encodeComponent(widget.imageFile);
    return '${_jubiladosBaseUrls[_baseUrlIndex]}/$encodedFile';
  }

  void _useNextUrl() {
    if (_baseUrlIndex < _jubiladosBaseUrls.length - 1) {
      setState(() {
        _baseUrlIndex++;
      });
    }
  }

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
            _currentImageUrl,
            key: ValueKey(_currentImageUrl),
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              if (_baseUrlIndex < _jubiladosBaseUrls.length - 1) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _useNextUrl();
                  }
                });
                return Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              return Container(
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.65),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Text(
                widget.topLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Text(
                widget.bottomLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
