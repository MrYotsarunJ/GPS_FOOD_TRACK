import 'package:flutter/material.dart';

class TruckStatusCard extends StatelessWidget {
  const TruckStatusCard({
    required this.usingMockLocation,
    required this.latitude,
    required this.longitude,
    required this.truckCount,
    required this.loadingRoutes,
    required this.routeStatus,
    required this.onRetry,
    super.key,
  });

  final bool usingMockLocation;
  final double latitude;
  final double longitude;
  final int truckCount;
  final bool loadingRoutes;
  final String routeStatus;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final routeLoaded = routeStatus.contains('สำเร็จ');

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LIVE FOOD TRUCKS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_pin_circle, color: Colors.green),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    usingMockLocation
                        ? 'User: Demo location'
                        : 'User: GPS location',
                  ),
                ),
                const Icon(Icons.local_shipping, color: Colors.orange),
                Text(' $truckCount trucks'),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Lat: ${latitude.toStringAsFixed(5)}, '
              'Lng: ${longitude.toStringAsFixed(5)}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (loadingRoutes)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    routeLoaded ? Icons.check_circle : Icons.info_outline,
                    size: 18,
                    color: routeLoaded ? Colors.green : Colors.orange,
                  ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    routeStatus,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            if (!loadingRoutes && !routeLoaded)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onRetry,
                  child: const Text('ลองอีกครั้ง'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
