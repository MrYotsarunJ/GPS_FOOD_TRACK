import 'package:flutter/material.dart';

import '../models/truck.dart';
import 'truck_progress_row.dart';

class TruckControlPanel extends StatelessWidget {
  const TruckControlPanel({
    required this.trucks,
    required this.loadingRoutes,
    required this.playing,
    required this.onToggleSimulation,
    super.key,
  });

  final List<Truck> trucks;
  final bool loadingRoutes;
  final bool playing;
  final VoidCallback onToggleSimulation;

  @override
  Widget build(BuildContext context) {
    final allTrucksArrived = trucks.every((truck) => truck.arrived);

    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...trucks.map((truck) => TruckProgressRow(truck: truck)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: loadingRoutes ? null : onToggleSimulation,
                icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                label: Text(
                  loadingRoutes
                      ? 'กำลังโหลดเส้นทาง...'
                      : playing
                          ? 'หยุดจำลองการเดินรถ'
                          : allTrucksArrived
                              ? 'เริ่มรอบใหม่'
                              : 'จำลองการเดินรถ',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
