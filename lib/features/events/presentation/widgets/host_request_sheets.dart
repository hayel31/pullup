import 'package:pullup/l10n/app_material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/pullup_chip.dart';
import '../../../../core/widgets/pullup_image.dart';
import '../../../../models/enums.dart';
import '../../../../models/event_request.dart';
import '../../../../models/party_event.dart';
import '../../../../models/user_profile.dart';

class HostAccessDraft {
  const HostAccessDraft({
    required this.exactAddress,
    required this.accessInstructions,
  });

  final String exactAddress;
  final String accessInstructions;
}

Future<HostAccessDraft?> showHostAccessEditor(
  BuildContext context, {
  required PartyEvent event,
}) {
  return showModalBottomSheet<HostAccessDraft>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _AccessEditorSheet(event: event),
  );
}

Future<bool> showApproveRequestSheet(
  BuildContext context, {
  required PartyEvent event,
  required EventRequest request,
  required UserProfile guest,
}) async {
  final canShareAccess = event.exactAddress?.trim().isNotEmpty ?? false;
  final remaining = event.availableSpots - request.groupSize;
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('Approve {name}?', values: {'name': guest.firstName}),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              context.tr(
                '{count} spots will be reserved.',
                values: {'count': request.groupSize},
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _DecisionMetric(
                    label: 'Group size',
                    value: '${request.groupSize}',
                    icon: Icons.group_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DecisionMetric(
                    label: 'Spots after',
                    value: '${remaining.clamp(0, event.maxParticipants)}',
                    icon: Icons.event_seat_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: canShareAccess
                      ? AppColors.success.withValues(alpha: 0.55)
                      : AppColors.warning,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        canShareAccess
                            ? Icons.lock_open_rounded
                            : Icons.warning_amber_rounded,
                        color: canShareAccess
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Access that will unlock',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(event.exactAddress ?? 'Address not configured'),
                  if ((event.accessInstructions ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      event.accessInstructions!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (!canShareAccess) ...[
                    const SizedBox(height: 7),
                    Text(
                      'Add private access before accepting guests.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.warning),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.forum_outlined,
                  size: 19,
                  color: AppColors.primaryBright,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Approval creates a match and opens a private conversation.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const Key('confirm-approve-request'),
              onPressed: canShareAccess
                  ? () => Navigator.of(context).pop(true)
                  : null,
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Approve and unlock access'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep request pending'),
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

Future<String?> showDeclineRequestSheet(
  BuildContext context, {
  required UserProfile guest,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _DeclineRequestSheet(guest: guest),
  );
}

Future<bool> confirmBlockGuest(
  BuildContext context, {
  required UserProfile guest,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        context.tr('Block {name}?', values: {'name': guest.firstName}),
      ),
      content: const Text(
        'You will no longer see each other or be able to interact.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          key: const Key('confirm-block-guest'),
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.block_rounded),
          label: const Text('Block user'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

Future<void> showGuestProfileSheet(
  BuildContext context, {
  required UserProfile guest,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      minChildSize: 0.55,
      maxChildSize: 0.94,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 260,
              child: PullupImage(
                source:
                    guest.mainPhotoUrl ??
                    (guest.profilePhotos.isEmpty
                        ? ''
                        : guest.profilePhotos.first),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${guest.displayName}, ${guest.age}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(guest.city, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 14),
          Text(guest.bio),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final badge in guest.badges)
                PullupChip(label: badge.label, icon: Icons.verified_rounded),
              for (final interest in guest.interests)
                PullupChip(label: interest),
            ],
          ),
          const SizedBox(height: 18),
          ListTile(
            leading: const Icon(Icons.translate_rounded),
            title: const Text('Languages'),
            subtitle: Text(guest.languages.join(', ')),
          ),
          ListTile(
            leading: const Icon(Icons.music_note_rounded),
            title: const Text('Music'),
            subtitle: Text(guest.musicPreferences.join(', ')),
          ),
          ListTile(
            leading: const Icon(Icons.celebration_outlined),
            title: const Text('Night history'),
            subtitle: Text(
              context.tr(
                '{count} nights joined',
                values: {'count': guest.guestAttendanceCount},
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _AccessEditorSheet extends StatefulWidget {
  const _AccessEditorSheet({required this.event});

  final PartyEvent event;

  @override
  State<_AccessEditorSheet> createState() => _AccessEditorSheetState();
}

class _AccessEditorSheetState extends State<_AccessEditorSheet> {
  late final TextEditingController _address;
  late final TextEditingController _instructions;

  @override
  void initState() {
    super.initState();
    _address = TextEditingController(text: widget.event.exactAddress);
    _instructions = TextEditingController(
      text: widget.event.accessInstructions,
    );
  }

  @override
  void dispose() {
    _address.dispose();
    _instructions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit private access',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Accepted guests can see these details immediately.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            TextField(
              key: const Key('host-access-address'),
              controller: _address,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: context.tr('Exact address'),
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('host-access-instructions'),
              controller: _instructions,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: context.tr('Access instructions'),
                hintText: context.tr(
                  'Door code, floor, entrance or arrival instructions',
                ),
                prefixIcon: const Icon(Icons.key_outlined),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              key: const Key('save-host-access'),
              onPressed: _save,
              icon: const Icon(Icons.lock_rounded),
              label: const Text('Save access'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_address.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add an exact address before saving.')),
      );
      return;
    }
    Navigator.of(context).pop(
      HostAccessDraft(
        exactAddress: _address.text.trim(),
        accessInstructions: _instructions.text.trim(),
      ),
    );
  }
}

class _DeclineRequestSheet extends StatefulWidget {
  const _DeclineRequestSheet({required this.guest});

  final UserProfile guest;

  @override
  State<_DeclineRequestSheet> createState() => _DeclineRequestSheetState();
}

class _DeclineRequestSheetState extends State<_DeclineRequestSheet> {
  static const _reasons = [
    'Guest list balance',
    'Group size does not fit',
    'Event is full',
    'Other',
  ];

  String _selected = _reasons.first;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr(
              'Decline {name}?',
              values: {'name': widget.guest.firstName},
            ),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Choose an internal reason. The guest receives a neutral update.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final reason in _reasons)
                ChoiceChip(
                  key: Key('decline-reason-$reason'),
                  label: Text(reason),
                  selected: _selected == reason,
                  onSelected: (_) => setState(() => _selected = reason),
                ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            key: const Key('confirm-decline-request'),
            onPressed: () => Navigator.of(context).pop(_selected),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            icon: const Icon(Icons.close_rounded),
            label: const Text('Decline request'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep request pending'),
          ),
        ],
      ),
    );
  }
}

class _DecisionMetric extends StatelessWidget {
  const _DecisionMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBright),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
