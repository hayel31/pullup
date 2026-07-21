import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'router.dart';
import 'theme/app_colors.dart';
import 'theme/app_palette.dart';
import 'theme/app_theme.dart';

class PullupApp extends ConsumerWidget {
  const PullupApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final themePreset = ref.watch(themePresetProvider);
    AppColors.apply(themePreset.palette);

    return MaterialApp.router(
      title: 'PULLUP',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.dark(),
      themeAnimationDuration: const Duration(milliseconds: 280),
      themeAnimationCurve: Curves.easeOutCubic,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final page = child ?? const SizedBox.shrink();
        if (mediaQuery.size.width < 720) {
          return page;
        }

        final appSize = Size(520, mediaQuery.size.height);
        return ColoredBox(
          color: AppColors.desktopBackground,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: AppColors.border),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 44,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SizedBox(
                width: appSize.width,
                height: appSize.height,
                child: MediaQuery(
                  data: mediaQuery.copyWith(size: appSize),
                  child: page,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
