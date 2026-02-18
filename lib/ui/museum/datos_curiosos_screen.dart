import 'package:flutter/material.dart';

class DatosCuriososScreen extends StatelessWidget {
  const DatosCuriososScreen({super.key});

  static const Color _color = Color(0xFFC9961A);

  @override
  Widget build(BuildContext context) {
    final datos = [
      _Dato(
        numero: '01',
        titulo: 'El edificio',
        contenido:
            'El edificio que alberga el museo es uno de los más emblemáticos '
            'de la Universidad de Mendoza, con una arquitectura que combina '
            'elementos clásicos y modernos.',
        icon: Icons.account_balance,
      ),
      _Dato(
        numero: '02',
        titulo: 'Colección permanente',
        contenido:
            'La colección permanente cuenta con más de 500 piezas entre '
            'pinturas, esculturas, fotografías históricas y documentos '
            'de valor cultural incalculable.',
        icon: Icons.collections,
      ),
      _Dato(
        numero: '03',
        titulo: 'Visitas anuales',
        contenido:
            'El museo recibe miles de visitantes cada año, incluyendo '
            'estudiantes de todos los niveles educativos, turistas y '
            'vecinos de la comunidad mendocina.',
        icon: Icons.people,
      ),
      _Dato(
        numero: '04',
        titulo: 'Exposiciones temporales',
        contenido:
            'A lo largo del año se realizan más de 10 exposiciones '
            'temporales que renuevan constantemente la propuesta cultural '
            'del museo.',
        icon: Icons.photo_library,
      ),
      _Dato(
        numero: '05',
        titulo: 'Arte local',
        contenido:
            'El museo dedica un espacio especial a artistas mendocinos, '
            'promoviendo el talento local y la expresión artística '
            'de la región cuyana.',
        icon: Icons.palette,
      ),
      _Dato(
        numero: '06',
        titulo: 'Acceso libre',
        contenido:
            'La entrada al museo es gratuita para todos los visitantes, '
            'reafirmando el compromiso con la democratización de la '
            'cultura y el acceso al arte.',
        icon: Icons.lock_open,
      ),
      _Dato(
        numero: '07',
        titulo: 'Historia viva',
        contenido:
            'Cada sala del museo cuenta una historia diferente de Mendoza, '
            'desde sus raíces precolombinas hasta la cultura '
            'contemporánea de la región.',
        icon: Icons.history_edu,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC9961A),
        title: const Text('Datos Curiosos'),
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
                  colors: [Color(0xFFC9961A), Color(0xFF8A6410)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.white, size: 44),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Sabías que...?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Descubrí los datos más fascinantes de nuestro museo',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...datos.map((dato) => _DatoCard(dato: dato, color: _color)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Dato {
  final String numero;
  final String titulo;
  final String contenido;
  final IconData icon;

  const _Dato({
    required this.numero,
    required this.titulo,
    required this.contenido,
    required this.icon,
  });
}

class _DatoCard extends StatelessWidget {
  final _Dato dato;
  final Color color;

  const _DatoCard({required this.dato, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(dato.icon, color: color, size: 28),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      dato.numero,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dato.titulo,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dato.contenido,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF555555),
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
