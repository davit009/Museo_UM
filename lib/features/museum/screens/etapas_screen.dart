import 'package:flutter/material.dart';

class EtapasScreen extends StatelessWidget {
  const EtapasScreen({super.key});

  static const Color _navy    = Color(0xFF0F1C35);
  static const Color _cream   = Color(0xFFF5F0E8);

  static const List<_EtapaData> _etapas = [
    _EtapaData(
      numero: '01',
      years: '1935 – 1942',
      titulo: 'Orígenes',
      subtitulo: 'Instituto Comercial Prosperidad',
      descripcion:
          'Ubicado en la Calle Prosperidad en Tacubaya, CDMX, inició '
          'como un pequeño internado para preparar misioneros bajo la '
          'dirección del pastor Alfred G. Parfitt.',
      color: Color(0xFF1B6B5A),
      icon: Icons.park_rounded,
    ),
    _EtapaData(
      numero: '02',
      years: '1942 – 1951',
      titulo: 'Primera Etapa',
      subtitulo: 'Escuela Agrícola Industrial Mexicana',
      descripcion:
          'Traslado a la hacienda "La Carlota" en Montemorelos. '
          'Inicio de la construcción de edificios emblemáticos y '
          'el primer templo en 1945, forjados con el esfuerzo manual.',
      color: Color(0xFF1A5272),
      icon: Icons.foundation_rounded,
    ),
    _EtapaData(
      numero: '03',
      years: '1951 – 1973',
      titulo: 'Segunda Etapa',
      subtitulo: 'COVOPROM',
      descripcion:
          'Cambio a Colegio Vocacional y Profesional. Destacó el '
          'desarrollo armónico de facultades, las industrias escolares '
          'y misiones aéreas lideradas por el pastor Baxter.',
      color: Color(0xFF3D3070),
      icon: Icons.flight_rounded,
    ),
    _EtapaData(
      numero: '04',
      years: '1973 – Presente',
      titulo: 'Tercera Etapa',
      subtitulo: 'Universidad de Montemorelos',
      descripcion:
          'Decretada oficialmente el 5 de mayo de 1973. Etapa de '
          'expansión académica global y excelencia profesional '
          'bajo el lema perpetuo "Educar es Redimir".',
      color: Color(0xFF6B2A00),
      icon: Icons.school_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _navy,
        title: const Text(
          'LAS ETAPAS',
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
            _HeroHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                children: [
                  for (int i = 0; i < _etapas.length; i++) ...[
                    _TimelineItem(
                      data: _etapas[i],
                      isLast: i == _etapas.length - 1,
                    ),
                  ],
                  const SizedBox(height: 8),
                  _ClosingQuote(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Datos de cada etapa ──────────────────────────────────────────────────────
class _EtapaData {
  final String numero;
  final String years;
  final String titulo;
  final String subtitulo;
  final String descripcion;
  final Color color;
  final IconData icon;

  const _EtapaData({
    required this.numero,
    required this.years,
    required this.titulo,
    required this.subtitulo,
    required this.descripcion,
    required this.color,
    required this.icon,
  });
}

// ── Hero header ──────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  static const Color _gold    = Color(0xFFB8973A);
  static const Color _goldLight = Color(0xFFD4AF5A);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F1C35), Color(0xFF1A2B4A), Color(0xFF0F1C35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Círculos decorativos
          Positioned(
            top: -40, right: -40,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gold.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -30, left: -30,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(84, 28, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Etiqueta superior
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: _gold.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(4),
                    color: _gold.withValues(alpha: 0.1),
                  ),
                  child: const Text(
                    'CRONOLOGÍA INSTITUCIONAL',
                    style: TextStyle(
                      color: _goldLight,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Tres Etapas,\nUn Sueño',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 14),
                // Separador dorado
                Row(
                  children: [
                    Container(width: 32, height: 1.5, color: _gold),
                    Container(
                      width: 5, height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: _gold),
                    ),
                    Expanded(child: Container(height: 1, color: _gold.withValues(alpha: 0.3))),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Nuestra historia recorre un camino de fe en donde la '
                  'naturaleza y el compromiso educativo han forjado el '
                  'espíritu de servicio que hoy nos define.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                    height: 1.65,
                  ),
                ),
                const SizedBox(height: 18),
                // Chips de años
                Row(
                  children: [
                    _YearChip(label: '1935'),
                    const SizedBox(width: 6),
                    Expanded(child: Container(height: 1, color: _gold.withValues(alpha: 0.35))),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, color: _goldLight, size: 14),
                    const SizedBox(width: 6),
                    Expanded(child: Container(height: 1, color: _gold.withValues(alpha: 0.35))),
                    const SizedBox(width: 6),
                    _YearChip(label: 'Hoy'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _YearChip extends StatelessWidget {
  final String label;
  const _YearChip({required this.label});

  static const Color _gold = Color(0xFFB8973A);
  static const Color _goldLight = Color(0xFFD4AF5A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _goldLight,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Item de la línea del tiempo ──────────────────────────────────────────────
class _TimelineItem extends StatelessWidget {
  final _EtapaData data;
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
          // Columna del timeline (línea + nodo)
          SizedBox(
            width: 52,
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Nodo circular
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [data.color, data.color.withValues(alpha: 0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: _gold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: data.color.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      data.numero,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                // Línea vertical hacia abajo
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _gold.withValues(alpha: 0.7),
                            _gold.withValues(alpha: 0.15),
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
          // Card de la etapa
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _gold.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: _navy.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Franja de color con número grande decorativo
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [data.color, data.color.withValues(alpha: 0.75)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Número decorativo de fondo
                            Positioned(
                              right: -4,
                              top: -10,
                              child: Text(
                                data.numero,
                                style: TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white.withValues(alpha: 0.1),
                                  height: 1,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Año
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    data.years,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  data.titulo,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Icon(data.icon, color: Colors.white.withValues(alpha: 0.8), size: 13),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        data.subtitulo,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.8),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Línea dorada
                      Container(
                        height: 2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6B5000), Color(0xFFD4AF5A), Color(0xFF6B5000)],
                          ),
                        ),
                      ),
                      // Descripción
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          data.descripcion,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.7,
                            color: Color(0xFF3A3A4A),
                          ),
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

// ── Cita de cierre ───────────────────────────────────────────────────────────
class _ClosingQuote extends StatelessWidget {
  static const Color _navy  = Color(0xFF0F1C35);
  static const Color _gold  = Color(0xFFB8973A);
  static const Color _goldLight = Color(0xFFD4AF5A);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F1C35), Color(0xFF1A2B4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _gold.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.format_quote_rounded, color: _goldLight, size: 32),
          const SizedBox(height: 10),
          const Text(
            'Cada etapa representa un capítulo de audacia espiritual en la historia de nuestra universidad.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.7,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: Container(height: 1, color: _gold.withValues(alpha: 0.3))),
              Container(
                width: 6, height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: _gold),
              ),
              Expanded(child: Container(height: 1, color: _gold.withValues(alpha: 0.3))),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '"EDUCAR ES REDIMIR"',
            style: TextStyle(
              color: _goldLight,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.5,
            ),
          ),
        ],
      ),
    );
  }
}
