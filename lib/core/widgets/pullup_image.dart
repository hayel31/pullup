import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class PullupImage extends StatelessWidget {
  const PullupImage({
    required this.source,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.placeholder,
    this.errorWidget,
    super.key,
  });

  final String source;
  final BoxFit fit;
  final Alignment alignment;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    final fallback = errorWidget ?? _defaultFallback;
    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        fit: fit,
        alignment: alignment,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    if (source.startsWith('data:image/')) {
      try {
        final separator = source.indexOf(',');
        if (separator == -1) return fallback;
        return Image.memory(
          base64Decode(source.substring(separator + 1)),
          fit: fit,
          alignment: alignment,
          filterQuality: FilterQuality.medium,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => fallback,
        );
      } on FormatException {
        return fallback;
      }
    }

    return CachedNetworkImage(
      imageUrl: source,
      fit: fit,
      alignment: alignment,
      fadeInDuration: const Duration(milliseconds: 220),
      placeholder: (_, _) => placeholder ?? _defaultPlaceholder,
      errorWidget: (_, _, _) => fallback,
    );
  }

  static Widget get _defaultPlaceholder => ColoredBox(
    color: AppColors.surfaceSecondary,
    child: Center(child: CircularProgressIndicator()),
  );

  static Widget get _defaultFallback => ColoredBox(
    color: AppColors.surfaceSecondary,
    child: Center(
      child: Icon(Icons.nightlife_rounded, color: AppColors.textSecondary),
    ),
  );
}
