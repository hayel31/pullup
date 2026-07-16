import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/distance_utils.dart';
import '../../../models/party_event.dart';
import '../../../models/user_profile.dart';

enum TonightViewMode { list, map }

enum TonightQuickFilter { all, happeningNow, startingSoon, fewSpots }

bool isTonightHappening(PartyEvent event, DateTime now) {
  return !now.isBefore(event.startDateTime) && now.isBefore(event.endDateTime);
}

bool isTonightStartingSoon(PartyEvent event, DateTime now) {
  final minutes = event.startDateTime.difference(now).inMinutes;
  return minutes >= 0 && minutes <= 180;
}

String tonightDistanceLabel(PartyEvent event, UserProfile viewer) {
  final distance = DistanceUtils.kilometersBetween(
    viewer.approximateLocation,
    event.approximateGeoPoint,
  );
  return distance < 10
      ? '${distance.toStringAsFixed(1)} km'
      : '${distance.round()} km';
}

String tonightShortStatus(PartyEvent event, DateTime now) {
  if (isTonightHappening(event, now)) return 'Happening now';
  final minutes = event.startDateTime.difference(now).inMinutes;
  if (minutes < 60) return 'Starts in $minutes min';
  return 'Starts in ${minutes ~/ 60}h ${minutes.remainder(60)}m';
}

Color tonightEventColor(PartyEvent event, DateTime now) {
  if (isTonightHappening(event, now)) return AppColors.success;
  if (event.isFewSpotsLeft) return AppColors.warning;
  if (isTonightStartingSoon(event, now)) return AppColors.magenta;
  return AppColors.blue;
}

String tonightFilterLabel(TonightQuickFilter filter) => switch (filter) {
  TonightQuickFilter.all => 'All',
  TonightQuickFilter.happeningNow => 'Live',
  TonightQuickFilter.startingSoon => 'Next 3h',
  TonightQuickFilter.fewSpots => 'Few spots',
};

String tonightFilterTitle(TonightQuickFilter filter) => switch (filter) {
  TonightQuickFilter.all => 'All plans',
  TonightQuickFilter.happeningNow => 'Happening now',
  TonightQuickFilter.startingSoon => 'Starting soon',
  TonightQuickFilter.fewSpots => 'Few spots left',
};

String tonightFilterSubtitle(TonightQuickFilter filter) => switch (filter) {
  TonightQuickFilter.all => 'Every available plan tonight',
  TonightQuickFilter.happeningNow => 'Already started and still open',
  TonightQuickFilter.startingSoon => 'Beginning in the next three hours',
  TonightQuickFilter.fewSpots => 'Guest lists that are almost full',
};

IconData tonightFilterIcon(TonightQuickFilter filter) => switch (filter) {
  TonightQuickFilter.all => Icons.nightlife_rounded,
  TonightQuickFilter.happeningNow => Icons.graphic_eq_rounded,
  TonightQuickFilter.startingSoon => Icons.bolt_rounded,
  TonightQuickFilter.fewSpots => Icons.local_fire_department_outlined,
};

Color tonightFilterColor(TonightQuickFilter filter) => switch (filter) {
  TonightQuickFilter.all => AppColors.primaryBright,
  TonightQuickFilter.happeningNow => AppColors.success,
  TonightQuickFilter.startingSoon => AppColors.magenta,
  TonightQuickFilter.fewSpots => AppColors.warning,
};
