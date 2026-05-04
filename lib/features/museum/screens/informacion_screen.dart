import 'package:flutter/material.dart';
import 'package:museo_app/features/admin/services/content_service.dart';

class InformacionScreen extends StatefulWidget {
  const InformacionScreen({super.key});
  @override
  State<InformacionScreen> createState() => _InformacionScreenState();
}

class _InformacionScreenState extends State<InformacionScreen> {
  final ContentService _svc = ContentService();
  Map<String, dynamic> _data = {};
  bool _loading = true;

  static const Color _navy  = Color(0xFF0F1C35);
  static const Color _cream = Color(0xFFF5F0E8);

  static const Map<String, String> _defaults = {
    'horario_lv': '9:00 – 18:00 hs',
    'horario_sabado': '10:00 – 16:00 hs',
    'horario_domingo': 'Cerrado',
    'precio_general': 'Gratuita',
    'precio_jubilados': 'Gratuita',
    'precio_estudiantes': 'Gratuita',
    'precio_grupos': 'Consultar',
    'telefono': '(826) 263-0900',
    'email': 'museo@um.edu.mx',
    'web': 'www.um.edu.mx',
    'instagram': '@um_mexico',
    'facebook': 'Universidad de Montemorelos',
    'servicio_1': 'Visitas guiadas en español',
    'servicio_2': 'Tienda de souvenirs y publicaciones',
    'servicio_3': 'Sala de lectura y consulta',
    'servicio_4': 'Wi-Fi gratuito',
    'servicio_5': 'Acceso para personas con discapacidad',
    'servicio_6': 'Estacionamiento en las inmediaciones',
  };

  String _v(String key) => ContentService.str(_data, key, _defaults[key] ?? '');

  @override
  void initState() {
    super.initState();
    _svc.loadSection('informacion').then((data) {
      if (mounted) setState(() { _data = data; _loading = false; });
    }).catchError((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F0E8),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFB8973A))),
      );
    }
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _navy,
        title: const Text(
          'INFORMACIÓN',
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
            _HeroBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(label: 'HORARIOS DE ATENCIÓN'),
                  const SizedBox(height: 14),
                  _HorariosCard(data: _data),
                  const SizedBox(height: 28),

                  _SectionLabel(label: 'PRECIOS DE ENTRADA'),
                  const SizedBox(height: 14),
                  _PreciosCard(data: _data),
                  const SizedBox(height: 28),

                  _SectionLabel(label: 'SERVICIOS'),
                  const SizedBox(height: 14),
                  _ServiciosCard(data: _data),
                  const SizedBox(height: 28),

                  _SectionLabel(label: 'CONTACTO'),
                  const SizedBox(height: 14),
                  _ContactoCard(data: _data),
                  const SizedBox(height: 28),

                  _SectionLabel(label: 'REDES SOCIALES'),
                  const SizedBox(height: 14),
                  _RedesCard(data: _data),
                ],
              ),
            ),
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
            top: -40, right: -40,
            child: Container(
              width: 150, height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gold.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(
                        color: _gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _gold.withValues(alpha: 0.45), width: 1.5),
                      ),
                      child: const Icon(Icons.museum_rounded, color: _goldLight, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VISÍTANOS',
                            style: TextStyle(
                              color: _goldLight,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Museo Universitario UM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
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
                const SizedBox(height: 14),
                const Text(
                  'Toda la información que necesitas para planificar tu visita al Museo Universitario de Montemorelos.',
                  style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.65),
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
            color: Color(0xFF0F1C35),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

// ── Base card ────────────────────────────────────────────────────────────────
class _BaseCard extends StatelessWidget {
  final Widget child;
  const _BaseCard({required this.child});

  static const Color _navy = Color(0xFF0F1C35);
  static const Color _gold = Color(0xFFB8973A);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _gold.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: child,
      ),
    );
  }
}

// ── Divisor interno ──────────────────────────────────────────────────────────
class _CardDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 2),
      color: const Color(0xFFB8973A).withValues(alpha: 0.1),
    );
  }
}

// ── Horarios ─────────────────────────────────────────────────────────────────
class _HorariosCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _HorariosCard({required this.data});

  String _v(String key, String fb) => ContentService.str(data, key, fb);

  List<(String, String, bool)> get _horarios => [
    ('Lunes a Viernes', _v('horario_lv', '9:00 – 18:00 hs'), false),
    ('Sábados', _v('horario_sabado', '10:00 – 16:00 hs'), false),
    ('Domingos y feriados', _v('horario_domingo', 'Cerrado'), _v('horario_domingo', 'Cerrado').toLowerCase().contains('cerr')),
  ];

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        children: [
          // Franja dorada superior
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B5000), Color(0xFFD4AF5A), Color(0xFF6B5000)],
              ),
            ),
          ),
          ...List.generate(_horarios.length, (i) {
            final (dia, hora, cerrado) = _horarios[i];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cerrado
                              ? Colors.red.withValues(alpha: 0.6)
                              : const Color(0xFFB8973A),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          dia,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF3A3A4A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cerrado
                              ? Colors.red.withValues(alpha: 0.08)
                              : const Color(0xFFB8973A).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: cerrado
                                ? Colors.red.withValues(alpha: 0.3)
                                : const Color(0xFFB8973A).withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          hora,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: cerrado ? Colors.red[700] : const Color(0xFF8B6914),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < _horarios.length - 1) _CardDivider(),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Precios ───────────────────────────────────────────────────────────────────
class _PreciosCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PreciosCard({required this.data});

  String _v(String key, String fb) => ContentService.str(data, key, fb);

  List<(String, String, bool)> get _precios {
    bool isGratis(String v) => v.toLowerCase().contains('gratu');
    return [
      ('Entrada general', _v('precio_general', 'Gratuita'), isGratis(_v('precio_general', 'Gratuita'))),
      ('Jubilados', _v('precio_jubilados', 'Gratuita'), isGratis(_v('precio_jubilados', 'Gratuita'))),
      ('Estudiantes', _v('precio_estudiantes', 'Gratuita'), isGratis(_v('precio_estudiantes', 'Gratuita'))),
      ('Visitas guiadas grupales', _v('precio_grupos', 'Consultar'), false),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        children: [
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B5000), Color(0xFFD4AF5A), Color(0xFF6B5000)],
              ),
            ),
          ),
          ...List.generate(_precios.length, (i) {
            final (cat, precio, gratuita) = _precios[i];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      Icon(
                        gratuita ? Icons.confirmation_num_rounded : Icons.info_outline_rounded,
                        size: 16,
                        color: gratuita ? const Color(0xFF1B6B5A) : const Color(0xFF0F1C35),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cat,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF3A3A4A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: gratuita
                              ? const LinearGradient(
                                  colors: [Color(0xFF1B6B5A), Color(0xFF2A9E82)],
                                )
                              : const LinearGradient(
                                  colors: [Color(0xFF0F1C35), Color(0xFF1A2B4A)],
                                ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          precio,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < _precios.length - 1) _CardDivider(),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Servicios ─────────────────────────────────────────────────────────────────
class _ServiciosCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ServiciosCard({required this.data});

  String _v(String key, String fb) => ContentService.str(data, key, fb);

  List<String> get _servicios => [
    _v('servicio_1', 'Visitas guiadas en español'),
    _v('servicio_2', 'Tienda de souvenirs y publicaciones'),
    _v('servicio_3', 'Sala de lectura y consulta'),
    _v('servicio_4', 'Wi-Fi gratuito'),
    _v('servicio_5', 'Acceso para personas con discapacidad'),
    _v('servicio_6', 'Estacionamiento en las inmediaciones'),
  ];

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        children: [
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B5000), Color(0xFFD4AF5A), Color(0xFF6B5000)],
              ),
            ),
          ),
          ...List.generate(_servicios.length, (i) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                  child: Row(
                    children: [
                      Container(
                        width: 26, height: 26,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB8973A).withValues(alpha: 0.13),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFB8973A).withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 15,
                          color: Color(0xFF8B6914),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _servicios[i],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF3A3A4A),
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < _servicios.length - 1) _CardDivider(),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Contacto ──────────────────────────────────────────────────────────────────
class _ContactoCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ContactoCard({required this.data});

  String _v(String key, String fb) => ContentService.str(data, key, fb);

  List<(IconData, String, String, Color)> get _contactos => [
    (Icons.phone_rounded, 'Teléfono', _v('telefono', '(826) 263-0900'), const Color(0xFF1B6B5A)),
    (Icons.email_rounded, 'Email', _v('email', 'museo@um.edu.mx'), const Color(0xFF1A5272)),
    (Icons.language_rounded, 'Web', _v('web', 'www.um.edu.mx'), const Color(0xFF3D3070)),
  ];

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        children: [
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B5000), Color(0xFFD4AF5A), Color(0xFF6B5000)],
              ),
            ),
          ),
          ...List.generate(_contactos.length, (i) {
            final (icon, label, valor, color) = _contactos[i];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: color.withValues(alpha: 0.3)),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFB8973A),
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            valor,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F1C35),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (i < _contactos.length - 1) _CardDivider(),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Redes sociales ────────────────────────────────────────────────────────────
class _RedesCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _RedesCard({required this.data});

  String _v(String key, String fb) => ContentService.str(data, key, fb);

  List<(IconData, String, String, Color)> get _redes => [
    (Icons.camera_alt_rounded, 'Instagram', _v('instagram', '@um_mexico'), const Color(0xFFE1306C)),
    (Icons.facebook_rounded, 'Facebook', _v('facebook', 'Universidad de Montemorelos'), const Color(0xFF1877F2)),
  ];

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        children: [
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B5000), Color(0xFFD4AF5A), Color(0xFF6B5000)],
              ),
            ),
          ),
          ...List.generate(_redes.length, (i) {
            final (icon, red, handle, color) = _redes[i];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: color.withValues(alpha: 0.3)),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            red.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: color,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            handle,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F1C35),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(
                        Icons.open_in_new_rounded,
                        size: 16,
                        color: color.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
                if (i < _redes.length - 1) _CardDivider(),
              ],
            );
          }),
        ],
      ),
    );
  }
}
