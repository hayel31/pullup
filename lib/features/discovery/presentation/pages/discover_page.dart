import 'dart:math' as math;

import 'package:pullup/l10n/app_material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/number_stepper.dart';
import '../../../../core/widgets/pullup_image.dart';
import '../../../../models/enums.dart';
import '../../../../models/party_event.dart';
import '../../../../models/user_profile.dart';
import '../../../shared/domain/app_drafts.dart';
import '../widgets/swipe_event_deck.dart';

Future<bool> showJoinEventSheet(
  BuildContext context, {
  required PartyEvent event,
}) async {
  HapticFeedback.selectionClick();
  return await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => _RequestSheet(event: event),
      ) ??
      false;
}

Future<bool> showEventEngagementSheet(
  BuildContext context, {
  required PartyEvent event,
}) async {
  HapticFeedback.selectionClick();
  return await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => _EventEngagementSheet(event: event),
      ) ??
      false;
}

String eventEngagementLabel(
  BuildContext context,
  UserProfile user,
  PartyEvent event,
) {
  final category = user.professionalCategory;
  if (category != null && event.needsProfessional(category)) {
    return context.tr(
      'Apply as {role}',
      values: {'role': context.tr(category.label)},
    );
  }
  if (event.acceptsOpenInterest) return context.tr("I'm interested");
  return context.tr('Request to join');
}

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  final _deckController = SwipeEventDeckController();
  final _swipeProgress = ValueNotifier<double>(0);

  @override
  void dispose() {
    _swipeProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final user = state.currentUser;
    final ranked = ref.watch(recommendedEventsProvider);
    if (user == null) return const LoadingView();

    if (ranked.isEmpty) {
      return EmptyStateView(
        title: 'No plans in range',
        message: 'Adjust filters or check Tonight for last-minute plans.',
        action: FilledButton.icon(
          onPressed: () => context.push('/filters'),
          icon: const Icon(Icons.tune_rounded),
          label: const Text('Open filters'),
        ),
      );
    }

    final event = ranked.first.event;
    final nextEvent = ranked.length > 1 ? ranked[1].event : null;
    final engagementLabel = eventEngagementLabel(context, user, event);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "What's the move tonight?",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton.filledTonal(
                tooltip: context.tr('Filters'),
                onPressed: () => context.push('/filters'),
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SwipeEventDeck(
              event: event,
              nextEvent: nextEvent,
              viewer: user,
              controller: _deckController,
              onProgressChanged: (progress) => _swipeProgress.value = progress,
              onPass: (event) =>
                  ref.read(appControllerProvider.notifier).passEvent(event.id),
              onRequest: (event) => _openRequestSheet(context, event),
              onDetails: () => context.push('/events/${event.id}'),
            ),
          ),
          const SizedBox(height: 14),
          ValueListenableBuilder<double>(
            valueListenable: _swipeProgress,
            builder: (context, progress, _) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SwipeActionButton(
                  icon: Icons.undo_rounded,
                  label: 'Premium undo',
                  activeColor: AppColors.primaryBright,
                  size: 50,
                  onTap: () =>
                      ref.read(appControllerProvider.notifier).undoLastSwipe(),
                ),
                const SizedBox(width: 22),
                _SwipeActionButton(
                  iconKey: const Key('pass-action-icon'),
                  icon: Icons.close_rounded,
                  label: 'Pass',
                  activeColor: AppColors.danger,
                  intensity: (-progress).clamp(0, 1),
                  onTap: () => _deckController.pass(),
                ),
                const SizedBox(width: 22),
                _SwipeActionButton(
                  iconKey: const Key('request-action-icon'),
                  icon: Icons.favorite_rounded,
                  label: engagementLabel,
                  activeColor: AppColors.magenta,
                  intensity: progress.clamp(0, 1),
                  onTap: () => _deckController.request(),
                ),
              ],
            ),
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              state.errorMessage!,
              style: const TextStyle(color: AppColors.danger),
            ),
          ],
        ],
      ),
    );
  }

  Future<bool> _openRequestSheet(BuildContext context, PartyEvent event) async {
    return showEventEngagementSheet(context, event: event);
  }
}

class _EventEngagementSheet extends ConsumerWidget {
  const _EventEngagementSheet({required this.event});

  final PartyEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appControllerProvider).currentUser;
    if (user == null) return const SizedBox.shrink();
    final category = user.professionalCategory;
    if (category != null && event.needsProfessional(category)) {
      return _ProfessionalApplicationSheet(event: event, user: user);
    }
    if (event.acceptsOpenInterest) {
      return _OpenInterestSheet(event: event);
    }
    return _RequestSheet(event: event);
  }
}

class _ProfessionalApplicationSheet extends ConsumerStatefulWidget {
  const _ProfessionalApplicationSheet({
    required this.event,
    required this.user,
  });

  final PartyEvent event;
  final UserProfile user;

  @override
  ConsumerState<_ProfessionalApplicationSheet> createState() =>
      _ProfessionalApplicationSheetState();
}

class _ProfessionalApplicationSheetState
    extends ConsumerState<_ProfessionalApplicationSheet> {
  late final TextEditingController _message;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.user.professionalProfile!;
    _message = TextEditingController(
      text:
          'Hi, ${profile.businessName} is available for this event. I would be happy to discuss the brief.',
    );
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.user.professionalProfile!;
    final error = ref.watch(
      appControllerProvider.select((state) => state.errorMessage),
    );
    return SafeArea(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          18,
          10,
          18,
          MediaQuery.viewInsetsOf(context).bottom + 18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.work_history_outlined,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Apply as ${profile.category.label}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.businessName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(profile.headline),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final service in profile.services.take(4))
                        Chip(label: Text(service)),
                      Chip(
                        avatar: const Icon(
                          Icons.collections_outlined,
                          size: 17,
                        ),
                        label: Text(
                          '${profile.portfolioItems.length} portfolio items',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Message to the host',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _message,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Availability, offer and useful details',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your full professional profile and portfolio will be attached. This does not reserve a guest spot.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            if (error != null) ...[
              const SizedBox(height: 10),
              Text(error, style: const TextStyle(color: AppColors.danger)),
            ],
            const SizedBox(height: 18),
            GradientButton(
              label: _submitting
                  ? 'Sending application...'
                  : 'Send application',
              icon: Icons.send_rounded,
              onPressed: _submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_message.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    await ref
        .read(appControllerProvider.notifier)
        .applyAsProfessional(widget.event.id, message: _message.text.trim());
    if (!mounted) return;
    if (ref.read(appControllerProvider).errorMessage == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _submitting = false);
    }
  }
}

class _OpenInterestSheet extends ConsumerStatefulWidget {
  const _OpenInterestSheet({required this.event});

  final PartyEvent event;

  @override
  ConsumerState<_OpenInterestSheet> createState() => _OpenInterestSheetState();
}

class _OpenInterestSheetState extends ConsumerState<_OpenInterestSheet> {
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final hostName =
        widget.event.hostPreview.businessName ??
        widget.event.hostPreview.firstName;
    final error = ref.watch(
      appControllerProvider.select((state) => state.errorMessage),
    );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.storefront_outlined,
                color: AppColors.blue,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Interested in ${widget.event.title}?",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '$hostName runs this as an open professional event. Your like is saved instantly; no approval request is sent.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 10),
              Text(error, style: const TextStyle(color: AppColors.danger)),
            ],
            const SizedBox(height: 20),
            GradientButton(
              label: _submitting ? 'Saving...' : "I'm interested",
              icon: Icons.favorite_rounded,
              onPressed: _submitting ? null : _submit,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _submitting
                  ? null
                  : () => Navigator.pop(context, false),
              child: const Text('Keep browsing'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await ref.read(appControllerProvider.notifier).likeEvent(widget.event.id);
    if (!mounted) return;
    if (ref.read(appControllerProvider).errorMessage == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _submitting = false);
    }
  }
}

class _RequestSheet extends ConsumerStatefulWidget {
  const _RequestSheet({required this.event});

  final PartyEvent event;

  @override
  ConsumerState<_RequestSheet> createState() => _RequestSheetState();
}

class _RequestSheetState extends ConsumerState<_RequestSheet> {
  final _note = TextEditingController();
  final Set<String> _selectedFriendIds = {};
  int _guestMenCount = 0;
  int _guestWomenCount = 0;
  bool _submitting = false;
  String? _groupLimitMessage;

  int get _groupSize =>
      1 + _selectedFriendIds.length + _guestMenCount + _guestWomenCount;

  int get _requestLimit {
    if (!widget.event.allowsGroups) return 1;
    return math.max(
      1,
      math.min(widget.event.maxGroupSize, widget.event.availableSpots),
    );
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = ref.watch(
      appControllerProvider.select((state) => state.errorMessage),
    );
    final state = ref.watch(appControllerProvider);
    final currentUser = state.currentUser;
    final friends = currentUser == null
        ? const <UserProfile>[]
        : state.users
              .where((user) => currentUser.friendIds.contains(user.id))
              .where(
                (user) =>
                    !user.blockedUserIds.contains(widget.event.hostId) &&
                    !currentUser.blockedUserIds.contains(user.id),
              )
              .toList();
    return SafeArea(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request to join',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              widget.event.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            Text('Add a note', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            TextField(
              controller: _note,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: context.tr(
                  'Tell the host who you are coming with or what you can bring.',
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final suggestion in const [
                  'I am coming with a friend.',
                  'I can bring drinks.',
                  'We are a group of three.',
                ])
                  ActionChip(
                    label: Text(suggestion),
                    onPressed: _submitting
                        ? null
                        : () => setState(() => _note.text = suggestion),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Your PULLUP friends',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: _submitting ? null : _openFriends,
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: const Text('Manage'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (friends.isEmpty)
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.group_add_outlined,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Add friends to identify them to the host and include them in the group chat.',
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 98,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: friends.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 9),
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    return _FriendPickerItem(
                      friend: friend,
                      selected: _selectedFriendIds.contains(friend.id),
                      onTap: _submitting
                          ? null
                          : () => _toggleFriend(friend.id),
                    );
                  },
                ),
              ),
            const SizedBox(height: 18),
            Text(
              'Guests without a PULLUP account',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'The host sees the composition, but only PULLUP members join the chat.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            NumberStepper(
              label: 'Men guests',
              value: _guestMenCount,
              minValue: 0,
              maxValue: _guestMenCount + (_requestLimit - _groupSize),
              decreaseButtonKey: const Key('guest-men-remove-button'),
              increaseButtonKey: const Key('guest-men-add-button'),
              helperText: context.tr('+ men'),
              onChanged: (value) => setState(() {
                _guestMenCount = value;
                _groupLimitMessage = null;
              }),
              onMaximumPressed: _submitting ? null : _showGroupLimit,
            ),
            const SizedBox(height: 10),
            NumberStepper(
              label: 'Women guests',
              value: _guestWomenCount,
              minValue: 0,
              maxValue: _guestWomenCount + (_requestLimit - _groupSize),
              decreaseButtonKey: const Key('guest-women-remove-button'),
              increaseButtonKey: const Key('guest-women-add-button'),
              helperText: context.tr('+ women'),
              onChanged: (value) => setState(() {
                _guestWomenCount = value;
                _groupLimitMessage = null;
              }),
              onMaximumPressed: _submitting ? null : _showGroupLimit,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryBright.withValues(alpha: 0.38),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.groups_rounded, color: AppColors.primaryBright),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.tr(
                        '{count} of {max} people in this request',
                        values: {'count': _groupSize, 'max': _requestLimit},
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            if (_groupLimitMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _groupLimitMessage!,
                style: const TextStyle(color: AppColors.warning),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                _groupLimitHelper,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                errorMessage,
                style: const TextStyle(color: AppColors.danger),
              ),
            ],
            const SizedBox(height: 18),
            GradientButton(
              label: _submitting ? 'Sending request...' : 'Request to pull up',
              icon: Icons.favorite_rounded,
              onPressed: _submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await ref
        .read(appControllerProvider.notifier)
        .requestToJoin(
          widget.event.id,
          JoinEventDraft(
            note: _note.text.trim(),
            groupSize: _groupSize,
            companionNames: const [],
            companionUserIds: _selectedFriendIds.toList(),
            guestMenCount: _guestMenCount,
            guestWomenCount: _guestWomenCount,
          ),
        );
    if (!mounted) return;
    final error = ref.read(appControllerProvider).errorMessage;
    if (error == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _submitting = false);
  }

  void _showGroupLimit() {
    HapticFeedback.selectionClick();
    setState(() {
      _groupLimitMessage = !widget.event.allowsGroups
          ? 'This host accepts individual requests only.'
          : _requestLimit == 1
          ? 'Maximum reached: only one spot is still available.'
          : 'Maximum reached: this event accepts up to $_requestLimit people in one request.';
    });
  }

  void _toggleFriend(String friendId) {
    if (_selectedFriendIds.contains(friendId)) {
      setState(() {
        _selectedFriendIds.remove(friendId);
        _groupLimitMessage = null;
      });
      return;
    }
    if (_groupSize >= _requestLimit) {
      _showGroupLimit();
      return;
    }
    setState(() {
      _selectedFriendIds.add(friendId);
      _groupLimitMessage = null;
    });
  }

  void _openFriends() {
    final router = GoRouter.of(context);
    Navigator.of(context).pop(false);
    router.push('/friends');
  }

  String get _groupLimitHelper {
    if (!widget.event.allowsGroups) {
      return 'This event accepts individual requests only.';
    }
    if (_requestLimit == 1) {
      return 'Only one spot is still available.';
    }
    return 'Up to $_requestLimit people, based on the host limit and spots left.';
  }
}

class _FriendPickerItem extends StatelessWidget {
  const _FriendPickerItem({
    required this.friend,
    required this.selected,
    required this.onTap,
  });

  final UserProfile friend;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final photo =
        friend.mainPhotoUrl ??
        (friend.profilePhotos.isEmpty ? '' : friend.profilePhotos.first);
    return Semantics(
      button: true,
      selected: selected,
      label: context.tr(
        '{name}, {status}',
        values: {
          'name': friend.displayName,
          'status': selected ? 'selected' : 'not selected',
        },
      ),
      child: InkWell(
        key: Key('request-friend-${friend.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 78,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.22)
                : AppColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.magenta : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: PullupImage(source: photo),
                    ),
                  ),
                  if (selected)
                    Positioned(
                      right: -3,
                      bottom: -2,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.magenta,
                        child: Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                friend.firstName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeActionButton extends StatelessWidget {
  const _SwipeActionButton({
    required this.icon,
    required this.label,
    required this.activeColor,
    required this.onTap,
    this.iconKey,
    this.intensity = 0,
    this.size = 64,
  });

  final IconData icon;
  final String label;
  final Color activeColor;
  final VoidCallback onTap;
  final Key? iconKey;
  final double intensity;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: intensity.clamp(0, 1)),
      duration: const Duration(milliseconds: 80),
      curve: Curves.easeOut,
      builder: (context, value, _) => Transform.scale(
        scale: 1 + (value * 0.12),
        child: Tooltip(
          message: context.tr(label),
          child: IconButton(
            onPressed: onTap,
            style: IconButton.styleFrom(
              fixedSize: Size.square(size),
              backgroundColor: Color.lerp(
                AppColors.surfaceSecondary,
                activeColor.withValues(alpha: 0.34),
                value,
              ),
              foregroundColor: Color.lerp(
                AppColors.textSecondary,
                activeColor,
                value,
              ),
              side: BorderSide(
                color: Color.lerp(AppColors.border, activeColor, value)!,
                width: 1 + value,
              ),
              shape: const CircleBorder(),
            ),
            icon: Icon(
              icon,
              key: iconKey,
              color: Color.lerp(AppColors.textSecondary, activeColor, value),
              size: size >= 60 ? 30 : 24,
            ),
          ),
        ),
      ),
    );
  }
}
