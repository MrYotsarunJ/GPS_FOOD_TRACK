import 'package:flutter/material.dart';

import '../models/truck.dart';

class TruckProgressRow extends StatelessWidget {
  const TruckProgressRow({
    required this.truck,
    super.key,
  });

  final Truck truck;

  @override
  Widget build(BuildContext context) {
    final progress = truck.route.length <= 1
        ? 1.0
        : truck.currentIndex / (truck.route.length - 1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping, color: truck.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  truck.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                truck.arrived ? 'ถึงปลายทาง' : '${(progress * 100).round()}%',
                style: TextStyle(
                  color: truck.arrived ? Colors.green : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(
            value: progress,
            color: truck.color,
            backgroundColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }
}
