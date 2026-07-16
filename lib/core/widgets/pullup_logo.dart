import 'package:pullup/l10n/app_material.dart';

import '../../app/constants/app_constants.dart';
import '../../app/theme/app_colors.dart';

class PullupLogo extends StatelessWidget {
  const PullupLogo({this.size = 72, super.key});

  static const assetPath = 'assets/branding/pullup-midnight-logo.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: context.tr('PULLUP logo'),
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
        excludeFromSemantics: true,
      ),
    );
  }
}

class PullupBrand extends StatelessWidget {
  const PullupBrand({this.logoSize = 30, this.showSlogan = false, super.key});

  final double logoSize;
  final bool showSlogan;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: showSlogan
          ? '${AppConstants.appName}. ${context.tr(AppConstants.slogan)}'
          : AppConstants.appName,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PullupLogo(size: logoSize),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              if (showSlogan) ...[
                const SizedBox(height: 3),
                const Text(
                  AppConstants.slogan,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.1,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
