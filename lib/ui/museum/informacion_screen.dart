import 'package:flutter/material.dart';

class InformacionScreen extends StatelessWidget {
  const InformacionScreen({super.key});

  static const Color _color = Color(0xFF1B6EA8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: _color,
        title: const Text('Información General'),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoSection(
              titulo: 'Horarios de Atención',
              icon: Icons.access_time,
              color: _color,
              children: const [
                _HorarioRow(dia: 'Lunes a Viernes', horario: '9:00 - 18:00 hs'),
                _HorarioRow(dia: 'Sábados', horario: '10:00 - 16:00 hs'),
                _HorarioRow(dia: 'Domingos y feriados', horario: 'Cerrado'),
              ],
            ),
            const SizedBox(height: 16),
            _InfoSection(
              titulo: 'Precios de Entrada',
              icon: Icons.confirmation_number,
              color: _color,
              children: const [
                _PrecioRow(categoria: 'Entrada general', precio: 'Gratuita'),
                _PrecioRow(categoria: 'Jubilados', precio: 'Gratuita'),
                _PrecioRow(categoria: 'Estudiantes', precio: 'Gratuita'),
                _PrecioRow(categoria: 'Visitas guiadas grupales', precio: 'Consultar'),
              ],
            ),
            const SizedBox(height: 16),
            _InfoSection(
              titulo: 'Servicios',
              icon: Icons.room_service,
              color: _color,
              children: const [
                _ServicioItem(texto: 'Visitas guiadas en español'),
                _ServicioItem(texto: 'Tienda de souvenirs y publicaciones'),
                _ServicioItem(texto: 'Sala de lectura y consulta'),
                _ServicioItem(texto: 'Wi-Fi gratuito'),
                _ServicioItem(texto: 'Acceso para personas con discapacidad'),
                _ServicioItem(texto: 'Estacionamiento en las inmediaciones'),
              ],
            ),
            const SizedBox(height: 16),
            _InfoSection(
              titulo: 'Contacto',
              icon: Icons.contact_phone,
              color: _color,
              children: const [
                _ContactoRow(
                  icon: Icons.phone,
                  label: 'Teléfono',
                  valor: '(0261) 000-0000',
                ),
                _ContactoRow(
                  icon: Icons.email,
                  label: 'Email',
                  valor: 'museo@um.edu.ar',
                ),
                _ContactoRow(
                  icon: Icons.web,
                  label: 'Web',
                  valor: 'www.um.edu.ar/museo',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoSection(
              titulo: 'Redes Sociales',
              icon: Icons.share,
              color: _color,
              children: const [
                _ContactoRow(
                  icon: Icons.camera_alt,
                  label: 'Instagram',
                  valor: '@museoumdoza',
                ),
                _ContactoRow(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  valor: 'Museo UM Mendoza',
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String titulo;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const _InfoSection({
    required this.titulo,
    required this.icon,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _HorarioRow extends StatelessWidget {
  final String dia;
  final String horario;

  const _HorarioRow({required this.dia, required this.horario});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(dia, style: const TextStyle(fontSize: 14, color: Color(0xFF444444))),
          Text(
            horario,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B6EA8),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrecioRow extends StatelessWidget {
  final String categoria;
  final String precio;

  const _PrecioRow({required this.categoria, required this.precio});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(categoria,
              style: const TextStyle(fontSize: 14, color: Color(0xFF444444))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF1B9E8A).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              precio,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B6EA8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicioItem extends StatelessWidget {
  final String texto;

  const _ServicioItem({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF1B9E8A), size: 18),
          const SizedBox(width: 10),
          Text(texto,
              style: const TextStyle(fontSize: 14, color: Color(0xFF444444))),
        ],
      ),
    );
  }
}

class _ContactoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;

  const _ContactoRow({
    required this.icon,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1B6EA8), size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
              ),
              Text(
                valor,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2B4A)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
