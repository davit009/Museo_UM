import 'package:flutter/material.dart';

class EtapasScreen extends StatelessWidget {
  const EtapasScreen({super.key});

  static const Color _darkNavy = Color(0xFF1A2B4A);
  static const Color _accent = Color(0xFF2E7D9A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: _accent,
        title: const Text('Las 3 Etapas'),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner El Origen
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A2B4A), Color(0xFF2E7D9A)],
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
                      Icon(Icons.history, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Text(
                        'El Origen',
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
                    'El museo nació como un proyecto de preservación cultural '
                    'y educativa, con el objetivo de acercar el patrimonio '
                    'histórico y artístico de Mendoza a toda la comunidad.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Las Tres Etapas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _darkNavy,
              ),
            ),
            const SizedBox(height: 16),
            _EtapaCard(
              numero: '01',
              titulo: 'Primera Etapa',
              subtitulo: 'Los comienzos',
              descripcion:
                  'Los primeros años del museo estuvieron marcados por la '
                  'recolección y catalogación del patrimonio histórico local. '
                  'Se establecieron las bases de la colección permanente con '
                  'piezas arqueológicas y documentos históricos de la región.',
              color: const Color(0xFF1B9E8A),
              icon: Icons.foundation,
            ),
            const SizedBox(height: 12),
            _EtapaCard(
              numero: '02',
              titulo: 'Segunda Etapa',
              subtitulo: 'Crecimiento y consolidación',
              descripcion:
                  'Durante esta etapa, el museo amplió sus colecciones '
                  'incorporando obras de arte y expresiones culturales '
                  'contemporáneas. Se inauguraron nuevas salas de exposición '
                  'y se establecieron programas educativos para escuelas.',
              color: const Color(0xFF2E7D9A),
              icon: Icons.trending_up,
            ),
            const SizedBox(height: 12),
            _EtapaCard(
              numero: '03',
              titulo: 'Tercera Etapa',
              subtitulo: 'Modernización y apertura',
              descripcion:
                  'La etapa actual se caracteriza por la renovación de espacios, '
                  'la incorporación de tecnología digital en las exposiciones '
                  'y la apertura a propuestas artísticas de diversas disciplinas. '
                  'El museo se posiciona como centro cultural referente de Mendoza.',
              color: const Color(0xFF5B6FA0),
              icon: Icons.rocket_launch,
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFBE3D).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFEFBE3D).withValues(alpha: 0.5),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb, color: Color(0xFFC9961A), size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cada etapa representa un capítulo único en la historia '
                      'de nuestro museo y su compromiso con la cultura mendocina.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7A5C00),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _EtapaCard extends StatelessWidget {
  final String numero;
  final String titulo;
  final String subtitulo;
  final String descripcion;
  final Color color;
  final IconData icon;

  const _EtapaCard({
    required this.numero,
    required this.titulo,
    required this.subtitulo,
    required this.descripcion,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Text(
                  numero,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.3),
                    height: 1,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitulo,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 32),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              descripcion,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF555555),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
