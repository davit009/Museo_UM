import 'package:flutter/material.dart';

class IntroHistoriaScreen extends StatelessWidget {
  const IntroHistoriaScreen({super.key});

  static const Color _navy  = Color(0xFF0F1C35);
  static const Color _cream = Color(0xFFF5F0E8);

  static const List<_TimelineData> _timeline = [
    _TimelineData(
      year: '1935',
      label: 'Orígenes',
      description:
          'Fundación del Instituto Comercial Prosperidad en la CDMX. '
          'Una pequeña semilla que contenía la grandeza de nuestra visión.',
      color: Color(0xFF1B6B5A),
    ),
    _TimelineData(
      year: '1942',
      label: 'El Traslado',
      description:
          'Nacimiento de la Escuela Agrícola Industrial Mexicana en '
          'la hacienda "La Carlota", Montemorelos.',
      color: Color(0xFF1A5272),
    ),
    _TimelineData(
      year: '1951',
      label: 'Crecimiento',
      description:
          'Autorización del Colegio Vocacional y Profesional (COVOPROM) '
          'y ampliación del nivel académico e industrial.',
      color: Color(0xFF3D3070),
    ),
    _TimelineData(
      year: '1973',
      label: 'Universidad',
      description:
          'Decreto oficial de creación de la Universidad de Montemorelos. '
          'Amanecer de una nueva era de excelencia profesional.',
      color: Color(0xFF6B2A00),
    ),
  ];

  static const List<_EsenciaData> _esencia = [
    _EsenciaData(
      icon: Icons.auto_awesome_rounded,
      title: 'Filosofía',
      content:
          'La verdadera educación significa el desarrollo armonioso '
          'de las facultades físicas, mentales y espirituales.',
    ),
    _EsenciaData(
      icon: Icons.format_quote_rounded,
      title: 'Nuestro Lema',
      content:
          '"Educar es Redimir", nuestro sello inalterable y compromiso '
          'eterno con Dios y la humanidad.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _navy,
        title: const Text(
          'HISTORIA',
          style: TextStyle(letterSpacing: 2.5, fontSize: 15, fontWeight: FontWeight.w700),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B5000), Color(0xFFD4AF5A), Color(0xFF6B5000)],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeroCard(
              icon: Icons.account_balance,
              color: _teal,
              title: 'George W. Caviness',
              subtitle: 'Corazón de nuestra memoria universitaria',
            ),
            const SizedBox(height: 20),
            _SectionTitle('Bienvenida e Historia', _darkNavy),
            const SizedBox(height: 12),
            _InfoCard(
              content:
                  'Bienvenidos al Museo Universitario. Aquí, '
                  'cada objeto guarda el eco de un sacrificio por la educación '
                  'adventista. Nuestra universidad ha trazado un camino de fe '
                  'que hoy nos toca continuar, recorriendo etapas que forjaron '
                  'nuestra identidad actual.',
            ),
            const SizedBox(height: 20),
            _SectionTitle('Línea del Tiempo', _darkNavy),
            const SizedBox(height: 12),
            _TimelineItem(
              year: '1935 - Orígenes',
              description:
                  'Fundación del Instituto Comercial Prosperidad en la CDMX. '
                  'Una pequeña semilla que contenía la grandeza de nuestra visión.',
              color: _teal,
              isFirst: true,
            ),
            _TimelineItem(
              year: '1942 - El Traslado',
              description:
                  'Nacimiento de la Escuela Agrícola Industrial Mexicana en '
                  'la hacienda "La Carlota", Montemorelos.',
              color: const Color(0xFF2E7D9A),
            ),
            _TimelineItem(
              year: '1951 - Crecimiento',
              description:
                  'Autorización del Colegio Vocacional y Profesional (COVOPROM) '
                  'y ampliación del nivel académico e industrial.',
              color: const Color(0xFF5B6FA0),
            ),
            _TimelineItem(
              year: '1973 - Universidad',
              description:
                  'Decreto oficial de creación de la Universidad de Montemorelos. '
                  'Amanecer de una nueva era de excelencia profesional.',
              color: _darkNavy,
              isLast: true,
            ),
            const SizedBox(height: 20),
            _SectionTitle('Nuestra Esencia', _darkNavy),
            const SizedBox(height: 12),
            _MisionCard(
              icon: Icons.star,
              title: 'Filosofía',
              content:
                  'La verdadera educación significa el desarrollo armonioso '
                  'de las facultades físicas, mentales y espirituales.',
              color: _teal,
            ),
            const SizedBox(height: 10),
            _MisionCard(
              icon: Icons.visibility,
              title: 'Nuestro Lema',
              content:
                  '"Educar es Redimir", nuestro sello inalterable y compromiso '
                  'eterno con Dios y la humanidad.',
              color: _darkNavy,
            ),
            const SizedBox(height: 24),

          ],
        ),
      ),
    );
  }
}



// ── Hero banner ──────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  static const Color _gold      = Color(0xFFB8973A);
  static const Color _goldLight = Color(0xFFD4AF5A);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F1C35), Color(0xFF1B3A5C), Color(0xFF0F1C35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50, right: -50,
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gold.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -40, left: -30,
            child: Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícono + nombre
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _gold.withValues(alpha: 0.15),
                        border: Border.all(color: _gold.withValues(alpha: 0.5), width: 1.5),
                      ),
                      child: const Icon(Icons.account_balance_rounded, color: _goldLight, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MUSEO UNIVERSITARIO',
                            style: TextStyle(
                              color: _goldLight,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'George W. Caviness',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                // Separador dorado
                Row(
                  children: [
                    Container(width: 32, height: 1.5, color: _gold),
                    Container(
                      width: 5, height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: _gold),
                    ),
                    Expanded(child: Container(height: 1, color: _gold.withValues(alpha: 0.28))),
                  ],
                ),
                const SizedBox(height: 20),
                // Cita
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote_rounded, color: _goldLight, size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: const Text(
                        'Corazón de nuestra memoria universitaria. '
                        'Una institución forjada en fe, naturaleza y compromiso.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.65,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Chip lema
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _gold.withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    '"EDUCAR ES REDIMIR"',
                    style: TextStyle(
                      color: _goldLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
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

// ── Etiqueta de sección ──────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  static const Color _navy = Color(0xFF0F1C35);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4, height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD4AF5A), Color(0xFFB8973A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: _navy,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

// ── Card de bienvenida ───────────────────────────────────────────────────────
class _WelcomeCard extends StatelessWidget {
  static const Color _navy = Color(0xFF0F1C35);
  static const Color _gold = Color(0xFFB8973A);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _gold.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Text(
        'Bienvenidos al Museo Universitario. Aquí, cada objeto guarda el eco '
        'de un sacrificio por la educación adventista. Nuestra universidad ha '
        'trazado un camino de fe que hoy nos toca continuar, recorriendo etapas '
        'que forjaron nuestra identidad actual.',
        style: TextStyle(
          fontSize: 14,
          height: 1.75,
          color: Color(0xFF3A3A4A),
        ),
      ),
    );
  }
}

// ── Item de la línea del tiempo ──────────────────────────────────────────────
class _TimelineItem extends StatelessWidget {
  final _TimelineData data;
  final bool isLast;
  const _TimelineItem({required this.data, required this.isLast});

  static const Color _navy = Color(0xFF0F1C35);
  static const Color _gold = Color(0xFFB8973A);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nodo + línea
          SizedBox(
            width: 44,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [data.color, data.color.withValues(alpha: 0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: _gold, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: data.color.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      data.year.substring(2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _gold.withValues(alpha: 0.6),
                            _gold.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _gold.withValues(alpha: 0.18)),
                  boxShadow: [
                    BoxShadow(
                      color: _navy.withValues(alpha: 0.07),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Franja de color
                      Container(
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [data.color, data.color.withValues(alpha: 0.5)],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: data.color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    data.year,
                                    style: TextStyle(
                                      color: data.color,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  data.label,
                                  style: TextStyle(
                                    color: data.color,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data.description,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.6,
                                color: Color(0xFF3A3A4A),
                              ),
                            ),
                          ],
                        ),
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

// ── Card de esencia ──────────────────────────────────────────────────────────
class _EsenciaCard extends StatelessWidget {
  final _EsenciaData data;
  const _EsenciaCard({required this.data});

  static const Color _navy      = Color(0xFF0F1C35);
  static const Color _gold      = Color(0xFFB8973A);
  static const Color _goldLight = Color(0xFFD4AF5A);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F1C35), Color(0xFF1A2B4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _gold.withValues(alpha: 0.4)),
            ),
            child: Icon(data.icon, color: _goldLight, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title.toUpperCase(),
                  style: const TextStyle(
                    color: _goldLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.content,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.6,
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


