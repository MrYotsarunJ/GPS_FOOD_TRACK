
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FoodTruckMapPage(),
      );
}

class Truck {
  Truck({
    required this.name,
    required this.color,
    required this.route,
    required this.currentIndex,
  });

  final String name;
  final Color color;
  final List<LatLng> route;
  int currentIndex;

  LatLng get current => route[currentIndex];
  LatLng get start => route.first;
  LatLng get destination => route.last;
}

class FoodTruckMapPage extends StatefulWidget {
  const FoodTruckMapPage({super.key});

  @override
  State<FoodTruckMapPage> createState() => _FoodTruckMapPageState();
}

class _FoodTruckMapPageState extends State<FoodTruckMapPage> {
  // Chiang Mai demo coordinates. Replace with real GPS when available.
  LatLng userPosition = const LatLng(18.7883, 98.9853);
  bool usingMockLocation = true;
  bool playing = false;
  Timer? timer;

  late final List<Truck> trucks = [
    Truck(
      name: 'Food Truck A',
      color: Colors.orange,
      currentIndex: 1,
      route: const [
        LatLng(18.8000, 98.9750), // Start
        LatLng(18.7960, 98.9790), // Current
        LatLng(18.7920, 98.9840),
        LatLng(18.7880, 98.9900), // Destination
      ],
    ),
    Truck(
      name: 'Food Truck B',
      color: Colors.blue,
      currentIndex: 1,
      route: const [
        LatLng(18.7800, 98.9750), // Start
        LatLng(18.7840, 98.9800), // Current
        LatLng(18.7890, 98.9860),
        LatLng(18.7950, 98.9920), // Destination
      ],
    ),
  ];

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> getUserLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        showMessage('กรุณาเปิด Location Service');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        showMessage('ไม่ได้รับอนุญาตให้เข้าถึงตำแหน่ง ใช้ตำแหน่งจำลองแทน');
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        userPosition = LatLng(position.latitude, position.longitude);
        usingMockLocation = false;
      });
    } catch (_) {
      showMessage('อ่าน GPS ไม่สำเร็จ ใช้ตำแหน่งจำลองแทน');
    }
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void toggleSimulation() {
    if (playing) {
      timer?.cancel();
      setState(() => playing = false);
      return;
    }

    setState(() => playing = true);
    timer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() {
        for (final truck in trucks) {
          if (truck.currentIndex < truck.route.length - 1) {
            truck.currentIndex++;
          } else {
            truck.currentIndex = 0;
          }
        }
      });
    });
  }

  Widget pin({
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
              BoxShadow(color: Colors.black26, blurRadius: 5),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Truck Tracking'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'ใช้ตำแหน่งปัจจุบัน',
            onPressed: getUserLocation,
            icon: const Icon(Icons.my_location),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: userPosition,
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.my_mobile_app',
              ),
              PolylineLayer(
                polylines: trucks.map((truck) {
                  return Polyline(
                    points: truck.route,
                    color: truck.color,
                    strokeWidth: 4,
                  );
                }).toList(),
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: userPosition,
                    width: 90,
                    height: 75,
                    child: pin(
                      icon: Icons.person_pin_circle,
                      color: Colors.green,
                      label: 'YOU',
                    ),
                  ),
                  ...trucks.expand((truck) => [
                    Marker(
                      point: truck.start,
                      width: 70,
                      height: 65,
                      child: pin(
                        icon: Icons.trip_origin,
                        color: truck.color,
                        label: 'START',
                      ),
                    ),
                    Marker(
                      point: truck.destination,
                      width: 70,
                      height: 65,
                      child: pin(
                        icon: Icons.flag,
                        color: truck.color,
                        label: 'END',
                      ),
                    ),
                    Marker(
                      point: truck.current,
                      width: 90,
                      height: 75,
                      child: pin(
                        icon: Icons.local_shipping,
                        color: truck.color,
                        label: truck.name,
                      ),
                    ),
                  ]),
                ],
              ),
            ],
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LIVE FOOD TRUCKS',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person_pin_circle,
                            color: Colors.green),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            usingMockLocation
                                ? 'User: Demo location'
                                : 'User: GPS location',
                          ),
                        ),
                        const Icon(Icons.local_shipping,
                            color: Colors.orange),
                        const Text(' 2 trucks'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Lat: ${userPosition.latitude.toStringAsFixed(5)}, '
                      'Lng: ${userPosition.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...trucks.map((truck) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.local_shipping, color: truck.color),
                          const SizedBox(width: 8),
                          Expanded(child: Text(truck.name)),
                          Text(
                            '${truck.currentIndex + 1}/${truck.route.length}',
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: toggleSimulation,
                        icon: Icon(
                          playing ? Icons.pause : Icons.play_arrow,
                        ),
                        label: Text(
                          playing ? 'หยุดจำลองการเดินรถ' : 'จำลองการเดินรถ',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
