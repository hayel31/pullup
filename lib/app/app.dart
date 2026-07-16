import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class PullupApp extends ConsumerWidget {
  const PullupApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'PULLUP',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.dark(),
      routerConfig: router,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final page = child ?? const SizedBox.shrink();
        if (mediaQuery.size.width < 720) {
          return page;
        }

        final appSize = Size(520, mediaQuery.size.height);
        return ColoredBox(
          color: const Color(0xFF050507),
          child: Center(
            child: SizedBox(
              width: appSize.width,
              height: appSize.height,
              child: MediaQuery(
                data: mediaQuery.copyWith(size: appSize),
                child: page,
              ),
            ),
          ),
        );
      },
    );
  }
}
