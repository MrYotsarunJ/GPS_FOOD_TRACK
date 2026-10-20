import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteService {
  Future<List<LatLng>> fetchRoadRoute(List<LatLng> waypoints) async {
    final coordinates = waypoints
        .map((point) => '${point.longitude},${point.latitude}')
        .join(';');

    final uri = Uri.https(
      'router.project-osrm.org',
      '/route/v1/driving/$coordinates',
      {
        'overview': 'full',
        'geometries': 'geojson',
        'steps': 'false',
      },
    );

    final response = await http.get(uri).timeout(
          const Duration(seconds: 25),
        );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body);

    if (data['code'] != 'Ok' || (data['routes'] as List).isEmpty) {
      throw Exception('ไม่พบเส้นทางถนนสำหรับพิกัดนี้');
    }

    final coordinatesList =
        data['routes'][0]['geometry']['coordinates'] as List;

    return coordinatesList.map<LatLng>((point) {
      return LatLng(
        (point[1] as num).toDouble(),
        (point[0] as num).toDouble(),
      );
    }).toList();
  }
}
