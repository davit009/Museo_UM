import 'package:flutter/material.dart';

class IntroHistoriaScreen extends StatelessWidget {
  const IntroHistoriaScreen({super.key});

  static const Color _darkNavy = Color(0xFF1A2B4A);
  static const Color _teal = Color(0xFF1B9E8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: _teal,
        title: const Text('Introducción e Historia'),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroCard(
              icon: Icons.account_balance,
              color: _teal,
              title: 'Nuestro Museo',
              subtitle: 'Un espacio de arte, cultura e historia',
            ),
            const SizedBox(height: 20),
            _SectionTitle('Historia del Museo', _darkNavy),
            const SizedBox(height: 12),
            _InfoCard(
              content:
                  'El museo de la Universidad de Mendoza es un espacio dedicado '
                  'a la preservación y difusión del patrimonio cultural y artístico '
                  'de la región. Fundado con el propósito de acercar el arte y la '
                  'historia a la comunidad, se ha convertido en un referente cultural '
                  'de la provincia.',
            ),
            const SizedBox(height: 20),
            _SectionTitle('Línea del Tiempo', _darkNavy),
            const SizedBox(height: 12),
            _TimelineItem(
              year: 'Fundación',
              description:
                  'Creación del museo como espacio cultural dentro de la '
                  'Universidad de Mendoza.',
              color: _teal,
              isFirst: true,
            ),
            _TimelineItem(
              year: 'Primeras colecciones',
              description:
                  'Incorporación de las primeras obras y piezas patrimoniales '
                  'a la colección permanente.',
              color: const Color(0xFF2E7D9A),
            ),
            _TimelineItem(
              year: 'Expansión',
              description:
                  'Ampliación de salas y apertura a nuevas expresiones artísticas '
                  'y culturales de la región.',
              color: const Color(0xFF5B6FA0),
            ),
            _TimelineItem(
              year: 'Actualidad',
              description:
                  'Espacio vivo de cultura con exposiciones temporales, eventos '
                  'educativos y programas para toda la comunidad.',
              color: _darkNavy,
              isLast: true,
            ),
            const SizedBox(height: 20),
            _SectionTitle('Misión y Visión', _darkNavy),
            const SizedBox(height: 12),
            _MisionCard(
              icon: Icons.star,
              title: 'Misión',
              content:
                  'Preservar, investigar y difundir el patrimonio cultural y '
                  'artístico, fomentando el acceso de la comunidad al conocimiento '
                  'y la cultura.',
              color: _teal,
            ),
            const SizedBox(height: 10),
            _MisionCard(
              icon: Icons.visibility,
              title: 'Visión',
              content:
                  'Ser un museo de referencia regional, reconocido por su '
                  'compromiso con la educación, la inclusión y la valorización '
                  'del patrimonio cultural mendocino.',
              color: _darkNavy,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _HeroCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 60, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final Color color;

  const _SectionTitle(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String content;

  const _InfoCard({required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          content,
          style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF444444)),
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String year;
  final String description;
  final Color color;
  final bool isFirst;
  final bool isLast;

  const _TimelineItem({
    required this.year,
    required this.description,
    required this.color,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Container(width: 2, height: 12, color: Colors.grey[300]),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: Colors.grey[300]),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 20),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        year,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF555555)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MisionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  const _MisionCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: const TextStyle(
                        fontSize: 14, height: 1.5, color: Color(0xFF555555)),
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
