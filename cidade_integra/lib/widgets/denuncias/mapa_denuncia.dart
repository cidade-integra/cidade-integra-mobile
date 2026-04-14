import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../utils/app_theme.dart';

class MapaDenuncia extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String? address;

  const MapaDenuncia({
    super.key,
    required this.latitude,
    required this.longitude,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 200,
            child: AbsorbPointer(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.cidadeIntegra',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_on,
                          color: AppColors.vermelho,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (address != null && address!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.place, size: 16, color: AppColors.textoSecundario),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    address!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textoSecundario,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class MapaFallback extends StatelessWidget {
  final String address;
  const MapaFallback({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordas),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, size: 24, color: AppColors.textoSecundario),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              address,
              style: TextStyle(fontSize: 14, color: AppColors.azul),
            ),
          ),
        ],
      ),
    );
  }
}
