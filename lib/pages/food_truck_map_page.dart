import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/truck.dart';
import '../services/location_service.dart';
import '../services/route_service.dart';
import '../widgets/truck_control_panel.dart';
import '../widgets/truck_map_view.dart';
import '../widgets/truck_status_card.dart';

class FoodTruckMapPage extends StatefulWidget {
  const FoodTruckMapPage({super.key});

  @override
  State<FoodTruckMapPage> createState() => _FoodTruckMapPageState();
}

class _FoodTruckMapPageState extends State<FoodTruckMapPage> {
  final MapController mapController = MapController();
  final RouteService routeService = RouteService();
  final LocationService locationService = LocationService();

  LatLng userPosition = const LatLng(18.7883, 98.9853);

  bool usingMockLocation = true;
  bool playing = false;
  bool loadingRoutes = true;
  bool showingNearbyDialog = false;

  String routeStatus = 'กำลังโหลดเส้นทางถนนจริง...';
  Timer? timer;

  static const double nearbyRadiusKm = 3.0;
  final Set<String> alertedTrucks = {};

  late final List<Truck> trucks = [
    Truck(
      name: 'Food Truck A',
      color: Colors.orange,
      waypoints: const [
        LatLng(18.8000, 98.9750),
        LatLng(18.7960, 98.9790),
        LatLng(18.7920, 98.9840),
        LatLng(18.7880, 98.9900),
      ],
    ),
    Truck(
      name: 'Food Truck B',
      color: Colors.blue,
      waypoints: const [
        LatLng(18.7800, 98.9750),
        LatLng(18.7840, 98.9800),
        LatLng(18.7890, 98.9860),
        LatLng(18.7950, 98.9920),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    loadTruckRoutes();
  }

  @override
  void dispose() {
    timer?.cancel();
    mapController.dispose();
    super.dispose();
  }

  Future<void> checkNearbyTrucks() async {
    if (!mounted) return;

    for (final truck in trucks) {
      final distanceKm = const Distance().as(
        LengthUnit.Kilometer,
        userPosition,
        truck.current,
      );

      if (distanceKm > nearbyRadiusKm) {
        alertedTrucks.remove(truck.name);
        continue;
      }

      if (!alertedTrucks.contains(truck.name)) {
        alertedTrucks.add(truck.name);
        if (showingNearbyDialog) continue;

        showingNearbyDialog = true;
        try {
          await showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (dialogContext) {
              return AlertDialog(
                icon: Icon(Icons.local_shipping, color: truck.color, size: 48),
                title: const Text(
                  'Food Truck อยู่ใกล้คุณ!',
                  textAlign: TextAlign.center,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      truck.name,
                      style: TextStyle(
                        color: truck.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'อยู่ห่างจากคุณ ${(distanceKm * 1000).round()} เมตร',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Food Truck กำลังเข้ามาใกล้คุณ '
                      'ในระยะ 3 กิโลเมตร',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: [
                  FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('รับทราบ'),
                  ),
                ],
              );
            },
          );
        } finally {
          showingNearbyDialog = false;
        }

        return;
      }
    }
  }

  Future<void> loadTruckRoutes() async {
    if (mounted) {
      setState(() {
        loadingRoutes = true;
        routeStatus = 'กำลังโหลดเส้นทางถนนจริง...';
      });
    }

    timer?.cancel();
    playing = false;

    try {
      final results = await Future.wait(
        trucks.map((truck) => routeService.fetchRoadRoute(truck.waypoints)),
      );

      if (!mounted) return;

      setState(() {
        for (var i = 0; i < trucks.length; i++) {
          trucks[i].route = results[i];
          trucks[i].currentIndex = 0;
        }
        loadingRoutes = false;
        routeStatus = 'โหลดเส้นทางถนนจริงสำเร็จ';
      });

      showMessage('โหลดเส้นทางถนนจริงสำเร็จ');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingRoutes = false;
        routeStatus = 'โหลดเส้นทางไม่สำเร็จ กรุณาลองใหม่';
      });
      showMessage('โหลดเส้นทางไม่สำเร็จ: $e');
    }
  }

  Future<void> getUserLocation() async {
    try {
      final location = await locationService.getCurrentLocation();
      if (!mounted) return;

      setState(() {
        userPosition = location;
        usingMockLocation = false;
      });
      mapController.move(userPosition, 15);
    } catch (e) {
      showMessage('อ่าน GPS ไม่สำเร็จ: $e');
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void toggleSimulation() {
    if (loadingRoutes) {
      showMessage('กรุณารอโหลดเส้นทางก่อน');
      return;
    }

    if (playing) {
      timer?.cancel();
      setState(() {
        playing = false;
      });
      return;
    }

    if (trucks.every((truck) => truck.arrived)) {
      for (final truck in trucks) {
        truck.currentIndex = 0;
      }
    }

    setState(() {
      playing = true;
    });

    timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) {
        timer?.cancel();
        return;
      }

      setState(() {
        for (final truck in trucks) {
          if (!truck.arrived) {
            truck.currentIndex++;
          }
        }

        if (trucks.every((truck) => truck.arrived)) {
          timer?.cancel();
          playing = false;
        }
      });

      checkNearbyTrucks();
    });
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
          IconButton(
            tooltip: 'โหลดเส้นทางใหม่',
            onPressed: loadingRoutes ? null : loadTruckRoutes,
            icon: const Icon(Icons.alt_route),
          ),
        ],
      ),
      body: Stack(
        children: [
          TruckMapView(
            mapController: mapController,
            userPosition: userPosition,
            trucks: trucks,
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: TruckStatusCard(
              usingMockLocation: usingMockLocation,
              latitude: userPosition.latitude,
              longitude: userPosition.longitude,
              truckCount: trucks.length,
              loadingRoutes: loadingRoutes,
              routeStatus: routeStatus,
              onRetry: loadTruckRoutes,
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 16,
            child: TruckControlPanel(
              trucks: trucks,
              loadingRoutes: loadingRoutes,
              playing: playing,
              onToggleSimulation: toggleSimulation,
            ),
          ),
        ],
      ),
    );
  }
}
