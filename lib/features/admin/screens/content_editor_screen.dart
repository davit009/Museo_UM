import 'package:flutter/material.dart';
import 'package:museo_app/features/admin/services/content_service.dart';

class ContentEditorScreen extends StatefulWidget {
  const ContentEditorScreen({super.key});
  @override
  State<ContentEditorScreen> createState() => _ContentEditorScreenState();
}

class _ContentEditorScreenState extends State<ContentEditorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final ContentService _svc = ContentService();

  static const Color _navy = Color(0xFF0F1C35);
  static const Color _gold = Color(0xFFB8973A);

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        title: const Text('Editor de Contenido',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1)),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: _gold,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: 'Información'),
            Tab(icon: Icon(Icons.history_edu), text: 'Historia'),
            Tab(icon: Icon(Icons.timeline), text: 'Etapas'),
          ],
        ),
      ),
      body: _buildTabView(),
    );
  }

  Widget _buildTabView() {
    return TabBarView(
      controller: _tabs,
      children: [
        _InformacionEditor(svc: _svc),
        _HistoriaEditor(svc: _svc),
        _EtapasEditor(svc: _svc),
      ],
    );
  }
}

// ── Widget reutilizable: campo editable con guardado ─────────────────────────
class _EditableField extends StatefulWidget {
  final String label;
  final String currentValue;
  final int maxLines;
  final Future<void> Function(String) onSave;

  const _EditableField({
    required this.label,
    required this.currentValue,
    required this.onSave,
    this.maxLines = 1,
  });

  @override
  State<_EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<_EditableField> {
  late final TextEditingController _ctrl;
  bool _saving = false;
  bool _changed = false;

  static const Color _navy = Color(0xFF0F1C35);
  static const Color _gold = Color(0xFFB8973A);

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentValue);
    _ctrl.addListener(() => setState(() => _changed = _ctrl.text != widget.currentValue));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.onSave(_ctrl.text.trim());
      if (mounted) {
        setState(() { _saving = false; _changed = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Guardado'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _changed ? _gold : Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _navy.withValues(alpha: 0.04),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              children: [
                Icon(Icons.edit_note, size: 16, color: _gold),
                const SizedBox(width: 6),
                Expanded(child: Text(widget.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _navy.withValues(alpha: 0.7), letterSpacing: 0.5))),
                if (_changed)
                  _saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : GestureDetector(
                          onTap: _save,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(20)),
                            child: const Text('Guardar', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _ctrl,
              maxLines: widget.maxLines,
              style: const TextStyle(fontSize: 14, color: Color(0xFF2A2A3A)),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _gold, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sección de título ────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFB8973A)),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Color(0xFF0F1C35))),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// EDITOR DE INFORMACIÓN
// ══════════════════════════════════════════════════════════════════════════════
class _InformacionEditor extends StatefulWidget {
  final ContentService svc;
  const _InformacionEditor({required this.svc});
  @override
  State<_InformacionEditor> createState() => _InformacionEditorState();
}

class _InformacionEditorState extends State<_InformacionEditor> {
  Map<String, dynamic> _data = {};
  bool _loading = true;

  // Defaults
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
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await widget.svc.loadSection('informacion');
    if (mounted) setState(() { _data = data; _loading = false; });
  }

  String _val(String key) => ContentService.str(_data, key, _defaults[key] ?? '');

  Future<void> _save(String key, String value) =>
      widget.svc.saveBlock('informacion', key, value);

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _SectionHeader(title: 'HORARIOS', icon: Icons.access_time),
        _EditableField(label: 'Lunes a Viernes', currentValue: _val('horario_lv'), onSave: (v) => _save('horario_lv', v)),
        _EditableField(label: 'Sábados', currentValue: _val('horario_sabado'), onSave: (v) => _save('horario_sabado', v)),
        _EditableField(label: 'Domingos y feriados', currentValue: _val('horario_domingo'), onSave: (v) => _save('horario_domingo', v)),

        _SectionHeader(title: 'PRECIOS DE ENTRADA', icon: Icons.confirmation_num),
        _EditableField(label: 'Entrada general', currentValue: _val('precio_general'), onSave: (v) => _save('precio_general', v)),
        _EditableField(label: 'Jubilados', currentValue: _val('precio_jubilados'), onSave: (v) => _save('precio_jubilados', v)),
        _EditableField(label: 'Estudiantes', currentValue: _val('precio_estudiantes'), onSave: (v) => _save('precio_estudiantes', v)),
        _EditableField(label: 'Visitas guiadas grupales', currentValue: _val('precio_grupos'), onSave: (v) => _save('precio_grupos', v)),

        _SectionHeader(title: 'CONTACTO', icon: Icons.contact_mail),
        _EditableField(label: 'Teléfono', currentValue: _val('telefono'), onSave: (v) => _save('telefono', v)),
        _EditableField(label: 'Email', currentValue: _val('email'), onSave: (v) => _save('email', v)),
        _EditableField(label: 'Sitio Web', currentValue: _val('web'), onSave: (v) => _save('web', v)),
        _EditableField(label: 'Instagram', currentValue: _val('instagram'), onSave: (v) => _save('instagram', v)),
        _EditableField(label: 'Facebook', currentValue: _val('facebook'), onSave: (v) => _save('facebook', v)),


      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// EDITOR DE HISTORIA
// ══════════════════════════════════════════════════════════════════════════════
class _HistoriaEditor extends StatefulWidget {
  final ContentService svc;
  const _HistoriaEditor({required this.svc});
  @override
  State<_HistoriaEditor> createState() => _HistoriaEditorState();
}

class _HistoriaEditorState extends State<_HistoriaEditor> {
  Map<String, dynamic> _data = {};
  bool _loading = true;

  static const Map<String, String> _defaults = {
    'bienvenida': 'Bienvenidos a este espacio virtual dedicado a nuestra historia. A través de esta aplicación, exploraremos el legado de fe y sacrificio por la educación adventista. Nuestra universidad ha trazado un camino que hoy nos toca continuar, recordando las etapas que forjaron nuestra identidad actual.',
    'cita_banner': 'Corazón de nuestra memoria universitaria. Una institución forjada en fe, naturaleza y compromiso.',
    'lema': '\"EDUCAR ES REDIMIR\"',
    'filosofia': 'La verdadera educación significa el desarrollo armonioso de las facultades físicas, mentales y espirituales.',
    'lema_esencia': '\"Educar es Redimir\", nuestro sello inalterable y compromiso eterno con Dios y la humanidad.',
    // Timeline
    'tl_1935_label': 'Orígenes',
    'tl_1935_desc': 'Fundación del Instituto Comercial Prosperidad en la CDMX. Una pequeña semilla que contenía la grandeza de nuestra visión.',
    'tl_1942_label': 'El Traslado',
    'tl_1942_desc': 'Nacimiento de la Escuela Agrícola Industrial Mexicana en la hacienda "La Carlota", Montemorelos.',
    'tl_1951_label': 'Crecimiento',
    'tl_1951_desc': 'Autorización del Colegio Vocacional y Profesional (COVOPROM) y ampliación del nivel académico e industrial.',
    'tl_1973_label': 'Universidad',
    'tl_1973_desc': 'Decreto oficial de creación de la Universidad de Montemorelos. Amanecer de una nueva era de excelencia profesional.',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await widget.svc.loadSection('historia');
    if (mounted) setState(() { _data = data; _loading = false; });
  }

  String _val(String key) => ContentService.str(_data, key, _defaults[key] ?? '');
  Future<void> _save(String key, String v) => widget.svc.saveBlock('historia', key, v);

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _SectionHeader(title: 'BANNER PRINCIPAL', icon: Icons.view_headline),
        _EditableField(label: 'Cita del banner', currentValue: _val('cita_banner'), maxLines: 3, onSave: (v) => _save('cita_banner', v)),
        _EditableField(label: 'Lema (chip)', currentValue: _val('lema'), onSave: (v) => _save('lema', v)),

        _SectionHeader(title: 'BIENVENIDA', icon: Icons.waving_hand),
        _EditableField(label: 'Texto de bienvenida', currentValue: _val('bienvenida'), maxLines: 5, onSave: (v) => _save('bienvenida', v)),

        _SectionHeader(title: 'NUESTRA ESENCIA', icon: Icons.auto_awesome),
        _EditableField(label: 'Filosofía', currentValue: _val('filosofia'), maxLines: 3, onSave: (v) => _save('filosofia', v)),
        _EditableField(label: 'Nuestro Lema', currentValue: _val('lema_esencia'), maxLines: 3, onSave: (v) => _save('lema_esencia', v)),

        _SectionHeader(title: 'LÍNEA DEL TIEMPO', icon: Icons.timeline),
        _EditableField(label: '1935 — Etiqueta', currentValue: _val('tl_1935_label'), onSave: (v) => _save('tl_1935_label', v)),
        _EditableField(label: '1935 — Descripción', currentValue: _val('tl_1935_desc'), maxLines: 3, onSave: (v) => _save('tl_1935_desc', v)),
        _EditableField(label: '1942 — Etiqueta', currentValue: _val('tl_1942_label'), onSave: (v) => _save('tl_1942_label', v)),
        _EditableField(label: '1942 — Descripción', currentValue: _val('tl_1942_desc'), maxLines: 3, onSave: (v) => _save('tl_1942_desc', v)),
        _EditableField(label: '1951 — Etiqueta', currentValue: _val('tl_1951_label'), onSave: (v) => _save('tl_1951_label', v)),
        _EditableField(label: '1951 — Descripción', currentValue: _val('tl_1951_desc'), maxLines: 3, onSave: (v) => _save('tl_1951_desc', v)),
        _EditableField(label: '1973 — Etiqueta', currentValue: _val('tl_1973_label'), onSave: (v) => _save('tl_1973_label', v)),
        _EditableField(label: '1973 — Descripción', currentValue: _val('tl_1973_desc'), maxLines: 3, onSave: (v) => _save('tl_1973_desc', v)),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// EDITOR DE ETAPAS
// ══════════════════════════════════════════════════════════════════════════════
class _EtapasEditor extends StatefulWidget {
  final ContentService svc;
  const _EtapasEditor({required this.svc});
  @override
  State<_EtapasEditor> createState() => _EtapasEditorState();
}

class _EtapasEditorState extends State<_EtapasEditor> {
  Map<String, dynamic> _data = {};
  bool _loading = true;

  static const Map<String, String> _defaults = {
    'hero_titulo': 'Tres Etapas,\nUn Sueño',
    'hero_desc': 'Nuestra historia recorre un camino de fe en donde la naturaleza y el compromiso educativo han forjado el espíritu de servicio que hoy nos define.',
    'cita_cierre': 'Cada etapa representa un capítulo de audacia espiritual en la historia de nuestra universidad.',
    'e1_years': '1935 – 1942',
    'e1_titulo': 'Orígenes',
    'e1_subtitulo': 'Instituto Comercial Prosperidad',
    'e1_desc': 'Ubicado en la Calle Prosperidad en Tacubaya, CDMX, inició como un pequeño internado para preparar misioneros bajo la dirección del pastor Alfred G. Parfitt.',
    'e2_years': '1942 – 1951',
    'e2_titulo': 'Primera Etapa',
    'e2_subtitulo': 'Escuela Agrícola Industrial Mexicana',
    'e2_desc': 'Traslado a la hacienda "La Carlota" en Montemorelos. Inicio de la construcción de edificios emblemáticos y el primer templo en 1945, forjados con el esfuerzo manual.',
    'e3_years': '1951 – 1973',
    'e3_titulo': 'Segunda Etapa',
    'e3_subtitulo': 'COVOPROM',
    'e3_desc': 'Cambio a Colegio Vocacional y Profesional. Destacó el desarrollo armónico de facultades, las industrias escolares y misiones aéreas lideradas por el pastor Baxter.',
    'e4_years': '1973 – Presente',
    'e4_titulo': 'Tercera Etapa',
    'e4_subtitulo': 'Universidad de Montemorelos',
    'e4_desc': 'Decretada oficialmente el 5 de mayo de 1973. Etapa de expansión académica global y excelencia profesional bajo el lema perpetuo "Educar es Redimir".',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await widget.svc.loadSection('etapas');
    if (mounted) setState(() { _data = data; _loading = false; });
  }

  String _val(String key) => ContentService.str(_data, key, _defaults[key] ?? '');
  Future<void> _save(String key, String v) => widget.svc.saveBlock('etapas', key, v);

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _SectionHeader(title: 'ENCABEZADO', icon: Icons.view_headline),
        _EditableField(label: 'Título principal', currentValue: _val('hero_titulo'), maxLines: 2, onSave: (v) => _save('hero_titulo', v)),
        _EditableField(label: 'Descripción del encabezado', currentValue: _val('hero_desc'), maxLines: 4, onSave: (v) => _save('hero_desc', v)),
        _EditableField(label: 'Cita de cierre', currentValue: _val('cita_cierre'), maxLines: 3, onSave: (v) => _save('cita_cierre', v)),

        for (int i = 1; i <= 4; i++) ...[
          _SectionHeader(title: 'ETAPA $i', icon: Icons.looks_one_outlined),
          _EditableField(label: 'Período (años)', currentValue: _val('e${i}_years'), onSave: (v) => _save('e${i}_years', v)),
          _EditableField(label: 'Título', currentValue: _val('e${i}_titulo'), onSave: (v) => _save('e${i}_titulo', v)),
          _EditableField(label: 'Subtítulo', currentValue: _val('e${i}_subtitulo'), onSave: (v) => _save('e${i}_subtitulo', v)),
          _EditableField(label: 'Descripción', currentValue: _val('e${i}_desc'), maxLines: 4, onSave: (v) => _save('e${i}_desc', v)),
        ],
      ],
    );
  }
}
