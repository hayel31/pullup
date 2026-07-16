import 'package:pullup/l10n/app_material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/pullup_image.dart';

class TonightEventImage extends StatelessWidget {
  const TonightEventImage({required this.url, super.key});

  final String url;

  @override
  Widget build(BuildContext context) {
    return PullupImage(
      source: url,
      fit: BoxFit.cover,
      placeholder: const ColoredBox(
        color: AppColors.surfaceSecondary,
        child: Center(
          child: Icon(Icons.nightlife_rounded, color: AppColors.textSecondary),
        ),
      ),
      errorWidget: const ColoredBox(
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
