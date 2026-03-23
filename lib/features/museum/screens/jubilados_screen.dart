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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B6FA0), Color(0xFF3A4D7A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.people, color: Colors.white, size: 56),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Programa Jubilados',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Actividades y beneficios especiales para adultos mayores',
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
            const Text(
              'Beneficios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2B4A),
              ),
            ),
            const SizedBox(height: 12),
            _BeneficioItem(
              icon: Icons.confirmation_number,
              titulo: 'Entrada Gratuita',
              descripcion:
                  'Jubilados y pensionados con DNI o credencial ingresan sin cargo '
                  'todos los días de la semana.',
              color: _color,
            ),
            _BeneficioItem(
              icon: Icons.schedule,
              titulo: 'Horario Preferencial',
              descripcion:
                  'Atención especial de lunes a viernes de 10:00 a 12:00 hs, '
                  'con guías dedicados para este grupo.',
              color: _color,
            ),
            _BeneficioItem(
              icon: Icons.school,
              titulo: 'Talleres Educativos',
              descripcion:
                  'Talleres de arte, historia y cultura diseñados especialmente '
                  'para adultos mayores, con ritmo y contenido adaptado.',
              color: _color,
            ),
            _BeneficioItem(
              icon: Icons.accessible,
              titulo: 'Accesibilidad Total',
              descripcion:
                  'El museo cuenta con rampas, ascensores y personal de asistencia '
                  'para garantizar la plena accesibilidad.',
              color: _color,
            ),
            const SizedBox(height: 20),
            const Text(
              'Actividades del Mes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2B4A),
              ),
            ),
            const SizedBox(height: 12),
            _ActividadCard(
              dia: 'Lunes y Miércoles',
              actividad: 'Visita guiada a colección permanente',
              hora: '10:00 - 11:30 hs',
              color: _color,
            ),
            _ActividadCard(
              dia: 'Martes y Jueves',
              actividad: 'Taller de pintura y expresión artística',
              hora: '10:00 - 12:00 hs',
              color: const Color(0xFF3A4D7A),
            ),
            _ActividadCard(
              dia: 'Viernes',
              actividad: 'Charla histórica y proyección audiovisual',
              hora: '10:30 - 12:00 hs',
              color: const Color(0xFF1B9E8A),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _color.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF5B6FA0)),
                      SizedBox(width: 8),
                      Text(
                        'Requisitos',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A4D7A),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Presentar DNI o credencial de jubilado/pensionado\n'
                    '• Inscripción previa para talleres (cupos limitados)\n'
                    '• Acompañante con entrada normal',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF444444),
                      height: 1.6,
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

class _BeneficioItem extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String descripcion;
  final Color color;

  const _BeneficioItem({
    required this.icon,
    required this.titulo,
    required this.descripcion,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
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
                    descripcion,
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

class _ActividadCard extends StatelessWidget {
  final String dia;
  final String actividad;
  final String hora;
  final Color color;

  const _ActividadCard({
    required this.dia,
    required this.actividad,
    required this.hora,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dia,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    actividad,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A2B4A),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                hora,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
