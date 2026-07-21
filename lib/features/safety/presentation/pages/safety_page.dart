import 'package:pullup/l10n/app_material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/night_card.dart';
import '../../../../models/enums.dart';

class SafetyPage extends ConsumerStatefulWidget {
  const SafetyPage({super.key});

  @override
  ConsumerState<SafetyPage> createState() => _SafetyPageState();
}

class _SafetyPageState extends ConsumerState<SafetyPage> {
  ReportReason _reason = ReportReason.harassment;
  final _description = TextEditingController();

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final user = state.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Center')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NightCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community rules',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const _Rule('Respect people and private spaces.'),
                const _Rule('Never publish a private address.'),
                const _Rule(
                  'No harassment, violence, hate speech or illegal activity.',
                ),
                const _Rule('PULLUP is 18+ only.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          NightCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report something',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ReportReason>(
                  initialValue: _reason,
                  isExpanded: true,
                  items: [
                    for (final reason in ReportReason.values)
                      DropdownMenuItem(
                        value: reason,
                        child: Text(reason.label),
                      ),
                  ],
                  onChanged: (value) =>
                      setState(() => _reason = value ?? _reason),
                  decoration: InputDecoration(
                    labelText: context.tr('What happened?'),
                    prefixIcon: Icon(Icons.report_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _description,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: context.tr('Add details'),
                    hintText: context.tr(
                      'Share only what is needed to review this report.',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GradientButton(
                  label: 'Submit report',
                  icon: Icons.flag_rounded,
                  onPressed: () => ref
                      .read(appControllerProvider.notifier)
                      .report(
                        reason: _reason,
                        description: _description.text.trim().isEmpty
                            ? 'Report submitted from Safety Center.'
                            : _description.text.trim(),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Blocked users', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (user == null || user.blockedUserIds.isEmpty)
            const Text(
              'No blocked users.',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            for (final blockedId in user.blockedUserIds)
              ListTile(
                title: Text(
                  state.users
                          .where((item) => item.id == blockedId)
                          .firstOrNull
                          ?.displayName ??
                      blockedId,
                ),
                trailing: TextButton(
                  onPressed: () => ref
                      .read(appControllerProvider.notifier)
                      .unblockUser(blockedId),
                  child: const Text('Unblock'),
                ),
              ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.delete_forever_rounded),
            label: const Text('Manage account deletion'),
          ),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, size: 20, color: AppColors.primaryBright),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
