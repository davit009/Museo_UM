import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class ComoLlegarScreen extends StatelessWidget {
  const ComoLlegarScreen({super.key});

  static const Color _color = Color(0xFF2E9E5E);
  // Coordenadas de la Universidad de Montemor
  static const LatLng _umLocation = LatLng(25.191203, -99.8459058);

  Future<void> _openGoogleMaps() async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${_umLocation.latitude},${_umLocation.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

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
            // Mapa Interactive
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    FlutterMap(
                      options: const MapOptions(
                        initialCenter: _umLocation,
                        initialZoom: 16.0,
                        interactionOptions: InteractionOptions(
                          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.museo_app',
                        ),
                        const MarkerLayer(
                          markers: [
                            Marker(
                              point: _umLocation,
                              width: 60,
                              height: 60,
                              child: Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 50,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: FloatingActionButton.extended(
                        heroTag: 'maps_btn',
                        onPressed: _openGoogleMaps,
                        backgroundColor: _color,
                        icon: const Icon(Icons.map, color: Colors.white),
                        label: const Text(
                          'Abrir en Maps',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Dirección
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
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
                      child: const Icon(
                        Icons.location_city,
                        color: _color,
                        size: 28,
                      ),
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
                            'Universidad de Montemorelos',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1A2B4A),
                            ),
                          ),
                          Text(
                            'Av. Libertad 1300 Pte, Barrio Matamoros, Montemorelos, Nuevo León',
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
                      'El museo se encuentra dentro de las instalaciones de la Universidad de Montemorelos. '
                      'Para ingresar, puedes preguntar en la caseta de vigilancia de la universidad y te indicarán cómo llegar al museo.',
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
