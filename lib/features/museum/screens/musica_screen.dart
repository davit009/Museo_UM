import 'package:flutter/material.dart';

// ── Datos ─────────────────────────────────────────────────────────────────────

class _Evento {
  final String titulo;
  final String artista;
  final String dia;
  final String mes;
  final String hora;
  final String lugar;
  final List<Color> gradiente;
  const _Evento({
    required this.titulo,
    required this.artista,
    required this.dia,
    required this.mes,
    required this.hora,
    required this.lugar,
    required this.gradiente,
  });
}

const _eventos = [
  _Evento(
    titulo: 'Concierto Clásico',
    artista: 'Orquesta Sinfónica UM',
    dia: '20', mes: 'FEB',
    hora: '19:00 hs', lugar: 'Sala Principal',
    gradiente: [Color(0xFF7B5EA7), Color(0xFFD7447A)],
  ),
  _Evento(
    titulo: 'Folklore Mexicano',
    artista: 'Artistas locales',
    dia: '27', mes: 'FEB',
    hora: '18:30 hs', lugar: 'Patio Central',
    gradiente: [Color(0xFF1B9E8A), Color(0xFF0D6B5F)],
  ),
  _Evento(
    titulo: 'Jazz en el Museo',
    artista: 'Cuarteto en vivo',
    dia: '6', mes: 'MAR',
    hora: '20:00 hs', lugar: 'Sala Expo',
    gradiente: [Color(0xFF1A2B4A), Color(0xFF2E7D9A)],
  ),
  _Evento(
    titulo: 'Noche de Ópera',
    artista: 'Coro Universitario',
    dia: '14', mes: 'MAR',
    hora: '19:30 hs', lugar: 'Auditorio',
    gradiente: [Color(0xFFC32F27), Color(0xFF7B1515)],
  ),
];

class _Coleccion {
  final String titulo;
  final String subtitulo;
  final IconData icon;
  final List<Color> gradiente;
  const _Coleccion({
    required this.titulo,
    required this.subtitulo,
    required this.icon,
    required this.gradiente,
  });
}

const _colecciones = [
  _Coleccion(
    titulo: 'Archivo Sonoro',
    subtitulo: 'Grabaciones históricas',
    icon: Icons.library_music_rounded,
    gradiente: [Color(0xFFC9961A), Color(0xFF8A6410)],
  ),
  _Coleccion(
    titulo: 'Instrumentos',
    subtitulo: 'Exposición permanente',
    icon: Icons.piano_rounded,
    gradiente: [Color(0xFF5B6FA0), Color(0xFF3A4D7A)],
  ),
  _Coleccion(
    titulo: 'Patrimonio',
    subtitulo: 'Historia musical',
    icon: Icons.queue_music_rounded,
    gradiente: [Color(0xFF7B5EA7), Color(0xFF4A3570)],
  ),
  _Coleccion(
    titulo: 'Cantos Regionales',
    subtitulo: 'Norte de México',
    icon: Icons.mic_rounded,
    gradiente: [Color(0xFF1B9E8A), Color(0xFF0D6B5F)],
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class MusicaScreen extends StatelessWidget {
  const MusicaScreen({super.key});

  static const _purple = Color(0xFF7B5EA7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── Large-title AppBar (estilo Apple) ──────────────────────────
          SliverAppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            pinned: true,
            expandedHeight: 96,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _purple, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: _purple.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.music_note_rounded, color: _purple, size: 18),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              title: const Text(
                'Música',
                style: TextStyle(
                  color: Color(0xFF0F0F1A),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              collapseMode: CollapseMode.pin,
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Destacado ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                  child: _SectionHeader(
                    title: 'Destacado',
                    subtitle: 'Evento de temporada',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _FeaturedCard(evento: _eventos.first),
                ),

                const SizedBox(height: 32),

                // ── Próximos conciertos ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: _SectionHeader(
                    title: 'Próximos Conciertos',
                    hasArrow: true,
                  ),
                ),
                SizedBox(
                  height: 188,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _eventos.length,
                    itemBuilder: (_, i) => _EventoCard(evento: _eventos[i]),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Colección Sonora ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: _SectionHeader(
                    title: 'Colección Sonora',
                    subtitle: 'Patrimonio musical del museo',
                    hasArrow: true,
                  ),
                ),
                SizedBox(
                  height: 158,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _colecciones.length,
                    itemBuilder: (_, i) => _ColeccionCard(col: _colecciones[i]),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Talleres ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: _SectionHeader(title: 'Talleres'),
                ),
                ..._talleres.map((t) => _TallerTile(taller: t)),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Datos talleres ─────────────────────────────────────────────────────────────

final _talleres = [
  _TallerData(
    icon: Icons.music_note_rounded,
    titulo: 'Iniciación Musical',
    subtitulo: 'Niños y jóvenes · Todos los sábados',
    color: const Color(0xFF7B5EA7),
  ),
  _TallerData(
    icon: Icons.graphic_eq_rounded,
    titulo: 'Ritmo y Percusión',
    subtitulo: 'Adultos · Miércoles 17:00 hs',
    color: const Color(0xFF1B9E8A),
  ),
  _TallerData(
    icon: Icons.mic_external_on_rounded,
    titulo: 'Canto Coral',
    subtitulo: 'Todas las edades · Viernes 18:00 hs',
    color: const Color(0xFFC9961A),
  ),
];

class _TallerData {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final Color color;
  const _TallerData({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.color,
  });
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool hasArrow;

  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.hasArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F0F1A),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (hasArrow)
          Row(
            children: [
              Text(
                'Ver todo',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
            ],
          ),
      ],
    );
  }
}

// ── Featured card ─────────────────────────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  final _Evento evento;
  const _FeaturedCard({required this.evento});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 210,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Artwork gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: evento.gradiente,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Patrón decorativo de notas
            Positioned.fill(
              child: CustomPaint(painter: _MusicPatternPainter()),
            ),
            // Gradiente oscuro inferior
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.72),
                    ],
                    stops: const [0.35, 1.0],
                  ),
                ),
              ),
            ),
            // Badge "EN VIVO"
            Positioned(
              top: 14, left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  'DESTACADO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            // Info inferior
            Positioned(
              bottom: 16, left: 16, right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          evento.titulo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          evento.artista,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.80),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 10, offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: evento.gradiente.first,
                      size: 28,
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

// ── Evento card (horizontal) ──────────────────────────────────────────────────

class _EventoCard extends StatelessWidget {
  final _Evento evento;
  const _EventoCard({required this.evento});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      margin: const EdgeInsets.only(right: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Artwork
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 145, width: 145,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: evento.gradiente,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  CustomPaint(painter: _MusicPatternPainter(scale: 0.6)),
                  // Fecha sobre la imagen
                  Positioned(
                    bottom: 10, left: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          evento.dia,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          evento.mes,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            evento.titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F0F1A),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${evento.hora}  ·  ${evento.lugar}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Colección card (horizontal) ───────────────────────────────────────────────

class _ColeccionCard extends StatelessWidget {
  final _Coleccion col;
  const _ColeccionCard({required this.col});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: col.gradiente,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(col.icon, color: Colors.white.withValues(alpha: 0.75), size: 46),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            col.titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F0F1A),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            col.subtitulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Taller tile ───────────────────────────────────────────────────────────────

class _TallerTile extends StatelessWidget {
  final _TallerData taller;
  const _TallerTile({required this.taller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: taller.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(taller.icon, color: taller.color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taller.titulo,
                      style: const TextStyle(
                        color: Color(0xFF0F0F1A),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      taller.subtitulo,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300, size: 22),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 64),
            child: Divider(height: 24, color: Colors.grey.shade100),
          ),
        ],
      ),
    );
  }
}

// ── Decoración musical de fondo ───────────────────────────────────────────────

class _MusicPatternPainter extends CustomPainter {
  final double scale;
  const _MusicPatternPainter({this.scale = 1.0});

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final ps = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 1.5 * scale
      ..style = PaintingStyle.stroke;

    // Notas musicales decorativas
    _note(canvas, Offset(s.width * 0.72, s.height * 0.22), 22 * scale, p, ps);
    _note(canvas, Offset(s.width * 0.18, s.height * 0.55), 16 * scale, p, ps);
    _note(canvas, Offset(s.width * 0.85, s.height * 0.65), 14 * scale, p, ps);

    // Arco decorativo
    canvas.drawArc(
      Rect.fromCenter(center: Offset(s.width * 0.5, s.height * 0.5),
          width: s.width * 1.1, height: s.height * 0.9),
      0, 3.14,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.05)
        ..strokeWidth = 40 * scale
        ..style = PaintingStyle.stroke,
    );
  }

  void _note(Canvas c, Offset pos, double sz,
      Paint fill, Paint stroke) {
    // Cabeza
    c.drawOval(
      Rect.fromCenter(center: pos, width: sz * 1.3, height: sz * 0.9),
      fill,
    );
    c.drawOval(
      Rect.fromCenter(center: pos, width: sz * 1.3, height: sz * 0.9),
      stroke,
    );
    // Palo
    c.drawLine(
      Offset(pos.dx + sz * 0.6, pos.dy),
      Offset(pos.dx + sz * 0.6, pos.dy - sz * 2.6),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
