import 'package:flutter/material.dart';

class ComoLlegarScreen extends StatelessWidget {
  const ComoLlegarScreen({super.key});

  static const Color _color = Color(0xFF2E9E5E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: _color,
        title: const Text('Cómo Llegar'),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mapa placeholder
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _color.withValues(alpha: 0.8),
                    const Color(0xFF1A2B4A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map, color: Colors.white, size: 56),
                  const SizedBox(height: 10),
                  const Text(
                    'Ver en Google Maps',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toca para abrir la ubicación',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Dirección
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.location_on, color: _color, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dirección',
                            style: TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Universidad de Mendoza',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1A2B4A),
                            ),
                          ),
                          Text(
                            'Boulogne Sur Mer 683, Mendoza',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF555555),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Medios de Transporte',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2B4A),
              ),
            ),
            const SizedBox(height: 12),
            _TransporteCard(
              icon: Icons.directions_bus,
              titulo: 'Colectivo / Bus',
              descripcion:
                  'Líneas que pasan cerca: 50, 68, 70, 200. '
                  'Bajada en Boulogne Sur Mer o Rodríguez Peña.',
              color: _color,
            ),
            _TransporteCard(
              icon: Icons.directions_car,
              titulo: 'Auto particular',
              descripcion:
                  'Acceso por Boulogne Sur Mer o Godoy Cruz. '
                  'Estacionamiento disponible en la vía pública.',
              color: const Color(0xFF1B6EA8),
            ),
            _TransporteCard(
              icon: Icons.pedal_bike,
              titulo: 'Bicicleta',
              descripcion:
                  'Mendoza cuenta con red de ciclovías. '
                  'Bicicletero disponible en las inmediaciones del museo.',
              color: const Color(0xFF1B9E8A),
            ),
            _TransporteCard(
              icon: Icons.local_taxi,
              titulo: 'Taxi / Remis',
              descripcion:
                  'Servicio disponible en toda la ciudad. '
                  'También se puede usar aplicaciones de transporte.',
              color: const Color(0xFF7B5EA7),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _color.withValues(alpha: 0.3)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF2E9E5E), size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'El museo se encuentra en el corazón de Mendoza, '
                      'a pocos minutos del centro de la ciudad. '
                      'El acceso es fácil desde cualquier punto del Gran Mendoza.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2E5E3E),
                        height: 1.5,
                      ),
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

class _TransporteCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String descripcion;
  final Color color;

  const _TransporteCard({
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
              child: Icon(icon, color: color, size: 26),
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
