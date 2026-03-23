import 'package:flutter/material.dart';

class MusicaScreen extends StatelessWidget {
  const MusicaScreen({super.key});

  static const Color _color = Color(0xFF7B5EA7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: _color,
        title: const Text('Música'),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B5EA7), Color(0xFF4A3570)],
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
                      Icon(Icons.music_note, color: Colors.white, size: 40),
                      SizedBox(width: 12),
                      Text(
                        'Música en el Museo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Descubrí cómo la música forma parte de nuestra propuesta '
                    'cultural, desde conciertos en vivo hasta exposiciones '
                    'interactivas sobre la historia musical de Mendoza.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Próximos Eventos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2B4A),
              ),
            ),
            const SizedBox(height: 12),
            _EventoCard(
              titulo: 'Concierto de Música Clásica',
              descripcion: 'Orquesta de Cámara de Mendoza',
              fecha: '20 Feb',
              hora: '19:00 hs',
              lugar: 'Sala Principal',
              color: _color,
            ),
            _EventoCard(
              titulo: 'Folklore Mendocino',
              descripcion: 'Presentación de artistas locales',
              fecha: '27 Feb',
              hora: '18:30 hs',
              lugar: 'Patio Central',
              color: const Color(0xFF1B9E8A),
            ),
            _EventoCard(
              titulo: 'Jazz en el Museo',
              descripcion: 'Velada de jazz con cuarteto en vivo',
              fecha: '6 Mar',
              hora: '20:00 hs',
              lugar: 'Sala Exposiciones',
              color: const Color(0xFF2E7D9A),
            ),
            const SizedBox(height: 20),
            const Text(
              'Música y Patrimonio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2B4A),
              ),
            ),
            const SizedBox(height: 12),
            _InfoMusicalCard(
              icon: Icons.library_music,
              titulo: 'Archivo Sonoro',
              contenido:
                  'Colección de grabaciones históricas que documenta la '
                  'evolución musical de la provincia de Mendoza.',
            ),
            const SizedBox(height: 10),
            _InfoMusicalCard(
              icon: Icons.piano,
              titulo: 'Instrumentos en Exposición',
              contenido:
                  'Instrumentos musicales tradicionales y modernos que narran '
                  'la historia musical de la región, disponibles para apreciar '
                  'en la sala de música.',
            ),
            const SizedBox(height: 10),
            _InfoMusicalCard(
              icon: Icons.school,
              titulo: 'Talleres de Música',
              contenido:
                  'Actividades educativas para niños, jóvenes y adultos: '
                  'introducción a la música, ritmo y percusión, canto coral.',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _EventoCard extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final String fecha;
  final String hora;
  final String lugar;
  final Color color;

  const _EventoCard({
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.hora,
    required this.lugar,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    fecha.split(' ')[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    fecha.split(' ')[1],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1A2B4A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    descripcion,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 13, color: color),
                      const SizedBox(width: 3),
                      Text(
                        hora,
                        style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.place, size: 13, color: Colors.grey[500]),
                      const SizedBox(width: 3),
                      Text(
                        lugar,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoMusicalCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String contenido;

  const _InfoMusicalCard({
    required this.icon,
    required this.titulo,
    required this.contenido,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF7B5EA7).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF7B5EA7), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1A2B4A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contenido,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
