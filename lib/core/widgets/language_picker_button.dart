import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/locale_provider.dart';
import '../../app/theme/app_colors.dart';
import '../../l10n/app_language.dart';
import '../../l10n/app_material.dart';

class LanguagePickerButton extends ConsumerWidget {
  const LanguagePickerButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final selected = AppLanguage.fromCode(locale.languageCode);

    return PopupMenuButton<AppLanguage>(
      key: const Key('language-picker'),
      tooltip: context.tr('Language'),
      initialValue: selected,
      onSelected: ref.read(localeProvider.notifier).setLanguage,
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(minWidth: 190, maxWidth: 230),
      itemBuilder: (context) => [
        for (final language in AppLanguage.values)
          PopupMenuItem(
            value: language,
            child: Row(
              children: [
                Text(language.flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        language.nativeName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        language.countryName,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (language == selected)
                  const Icon(Icons.check_rounded, size: 18),
              ],
            ),
          ),
      ],
      child: Semantics(
        button: true,
        label: '${context.tr('Language')}: ${selected.nativeName}',
        child: SizedBox.square(
          dimension: 44,
          child: Center(
            child: Text(
              selected.flag,
              key: const Key('selected-language-flag'),
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}
