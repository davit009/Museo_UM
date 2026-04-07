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
                        'Tres Etapas, Un Sueño',
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
                    'Nuestra historia recorre un camino de fe en donde la '
                    'naturaleza y el compromiso educativo han forjado el '
                    'espíritu de servicio que hoy nos define.',
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
              'Nuestra Evolución',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _darkNavy,
              ),
            ),
            const SizedBox(height: 16),
            _EtapaCard(
              numero: '01',
              titulo: 'Orígenes (1935-1942)',
              subtitulo: 'Instituto Comercial Prosperidad',
              descripcion:
                  'Ubicado en la Calle Prosperidad en Tacubaya, CDMX, inició '
                  'como un pequeño internado para preparar misioneros bajo la '
                  'dirección del pastor Alfred G. Parfitt.',
              color: const Color(0xFF1B9E8A),
              icon: Icons.park,
            ),
            const SizedBox(height: 12),
            _EtapaCard(
              numero: '02',
              titulo: 'Primera Etapa (1942-1951)',
              subtitulo: 'Escuela Agrícola Industrial Mexicana',
              descripcion:
                  'Traslado a la hacienda "La Carlota" en Montemorelos. '
                  'Inicio de la construcción de edificios emblemáticos y '
                  'el primer templo en 1945, forjados con el esfuerzo manual.',
              color: const Color(0xFF2E7D9A),
              icon: Icons.foundation,
            ),
            const SizedBox(height: 12),
            _EtapaCard(
              numero: '03',
              titulo: 'Segunda Etapa (1951-1973)',
              subtitulo: 'COVOPROM',
              descripcion:
                  'Cambio a Colegio Vocacional y Profesional. Destacó el '
                  'desarrollo armónico de facultades, las industrias escolares '
                  'y misiones aéreas lideradas por el pastor Baxter.',
              color: const Color(0xFF5B6FA0),
              icon: Icons.airplanemode_active,
            ),
            const SizedBox(height: 12),
            _EtapaCard(
              numero: '04',
              titulo: 'Tercera Etapa (1973-Presente)',
              subtitulo: 'Universidad de Montemorelos',
              descripcion:
                  'Decretada oficialmente el 5 de mayo de 1973. Etapa de '
                  'expansión académica global y excelencia profesional '
                  'bajo el lema perpetuo "Educar es Redimir".',
              color: const Color(0xFF4A148C),
              icon: Icons.school,
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
                      'Cada etapa representa un capítulo de audacia espiritual '
                      'en la historia de nuestra universidad.',
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
