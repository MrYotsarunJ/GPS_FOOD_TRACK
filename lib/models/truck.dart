import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Truck {
  Truck({
    required this.name,
    required this.color,
    required this.waypoints,
  }) : route = List<LatLng>.from(waypoints);

  final String name;
  final Color color;
  final List<LatLng> waypoints;

  List<LatLng> route;
  int currentIndex = 0;

  LatLng get current => route[currentIndex];
  LatLng get start => waypoints.first;
  LatLng get destination => waypoints.last;

  bool get arrived => currentIndex >= route.length - 1;
}
