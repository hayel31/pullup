import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class TonightEventImage extends StatelessWidget {
  const TonightEventImage({required this.url, super.key});

  final String url;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, url) => const ColoredBox(
        color: AppColors.surfaceSecondary,
        child: Center(
          child: Icon(Icons.nightlife_rounded, color: AppColors.textSecondary),
        ),
      ),
      errorWidget: (context, url, error) => const ColoredBox(
        color: AppColors.surfaceSecondary,
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
