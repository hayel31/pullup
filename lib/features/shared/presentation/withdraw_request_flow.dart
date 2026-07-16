import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pullup/l10n/app_material.dart';

import '../../../app/providers/app_state.dart';
import '../../../app/theme/app_colors.dart';

Future<bool> confirmAndWithdrawRequest({
  required BuildContext context,
  required WidgetRef ref,
  required String requestId,
  required String eventTitle,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Withdraw this request?'),
      content: Text(
        context.tr(
          'Your request for {event} will be removed. You can request to join again later.',
          values: {'event': eventTitle},
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          key: const Key('confirm-withdraw-request'),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          icon: const Icon(Icons.close_rounded),
          label: const Text('Withdraw request'),
        ),
      ],
    ),
  );
  if (confirmed != true) return false;

  await ref.read(appControllerProvider.notifier).withdrawRequest(requestId);
  if (!context.mounted) return false;

  final errorMessage = ref.read(appControllerProvider).errorMessage;
  final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
  if (errorMessage != null) {
    messenger.showSnackBar(SnackBar(content: Text(context.tr(errorMessage))));
    return false;
  }

  messenger.showSnackBar(const SnackBar(content: Text('Request withdrawn.')));
  return true;
}
