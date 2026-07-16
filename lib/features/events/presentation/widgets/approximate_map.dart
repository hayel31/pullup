import 'package:pullup/l10n/app_material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../models/party_event.dart';

class ApproximateMap extends StatelessWidget {
  const ApproximateMap({required this.events, this.height = 220, super.key});

  final List<PartyEvent> events;
  final double height;

  @override
  Widget build(BuildContext context) {
    final center = events.isEmpty
        ? const LatLng(48.8566, 2.3522)
        : LatLng(
            events.first.approximateGeoPoint.latitude,
            events.first.approximateGeoPoint.longitude,
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: MapOptions(initialCenter: center, initialZoom: 12),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.pullupnight.pullup',
            ),
            CircleLayer(
              circles: [
                for (final event in events)
                  CircleMarker(
                    point: LatLng(
                      event.approximateGeoPoint.latitude,
                      event.approximateGeoPoint.longitude,
                    ),
                    color: AppColors.magenta.withValues(alpha: 0.22),
                    borderColor: AppColors.magenta,
                    borderStrokeWidth: 2,
                    radius: 260,
                    useRadiusInMeter: true,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
