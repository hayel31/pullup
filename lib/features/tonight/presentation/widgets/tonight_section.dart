import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../models/party_event.dart';
import '../../../../models/user_profile.dart';
import 'tonight_event_tile.dart';

class TonightSection extends StatelessWidget {
  const TonightSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.events,
    required this.viewer,
    this.topPadding = 22,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<PartyEvent> events;
  final UserProfile viewer;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${events.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final event in events) ...[
            TonightEventTile(event: event, viewer: viewer),
            if (event != events.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
