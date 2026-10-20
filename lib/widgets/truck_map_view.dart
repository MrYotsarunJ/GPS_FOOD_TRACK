import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/truck.dart';

class TruckMapView extends StatelessWidget {
  const TruckMapView({
    required this.mapController,
    required this.userPosition,
    required this.trucks,
    super.key,
  });

  final MapController mapController;
  final LatLng userPosition;
  final List<Truck> trucks;

  Widget _pin({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        Container(
          margin: const EdgeInsets.only(top: 3),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: userPosition,
        initialZoom: 14,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.my_mobile_app',
        ),
        PolylineLayer(
          polylines: trucks.map((truck) {
            return Polyline(
              points: truck.route,
              color: truck.color,
              strokeWidth: 5,
            );
          }).toList(),
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: userPosition,
              width: 90,
              height: 75,
              child: _pin(
                icon: Icons.person_pin_circle,
                color: Colors.green,
                label: 'YOU',
              ),
            ),
            ...trucks.expand(
              (truck) => [
                Marker(
                  point: truck.start,
                  width: 70,
                  height: 65,
                  child: _pin(
                    icon: Icons.trip_origin,
                    color: truck.color,
                    label: 'START',
                  ),
                ),
                Marker(
                  point: truck.destination,
                  width: 70,
                  height: 65,
                  child: _pin(
                    icon: Icons.flag,
                    color: truck.color,
                    label: 'END',
                  ),
                ),
                Marker(
                  point: truck.current,
                  width: 100,
                  height: 75,
                  child: _pin(
                    icon: Icons.local_shipping,
                    color: truck.color,
                    label: truck.name,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
