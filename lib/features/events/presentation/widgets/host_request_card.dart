import 'package:pullup/l10n/app_material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/night_card.dart';
import '../../../../core/widgets/pullup_chip.dart';
import '../../../../core/widgets/pullup_image.dart';
import '../../../../models/enums.dart';
import '../../../../models/event_request.dart';
import '../../../../models/party_event.dart';
import '../../../../models/user_profile.dart';

class HostRequestCard extends StatelessWidget {
  const HostRequestCard({
    required this.request,
    required this.guest,
    required this.event,
    this.companionProfiles = const [],
    required this.onViewProfile,
    required this.onBlock,
    this.onApprove,
    this.onDecline,
    this.onOpenChat,
    super.key,
  });

  final EventRequest request;
  final UserProfile guest;
  final PartyEvent event;
  final List<UserProfile> companionProfiles;
  final VoidCallback onViewProfile;
  final VoidCallback onBlock;
  final VoidCallback? onApprove;
  final VoidCallback? onDecline;
  final VoidCallback? onOpenChat;

  @override
  Widget build(BuildContext context) {
    final isProfessional = request.kind == EventRequestKind.professionalService;
    final professional = guest.professionalProfile;
    final canFit = event.availableSpots >= request.reservedSpots;
    return NightCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: SizedBox(
                  width: 62,
                  height: 62,
                  child: PullupImage(
                    source:
                        guest.mainPhotoUrl ??
                        (guest.profilePhotos.isEmpty
                            ? ''
                            : guest.profilePhotos.first),
                    fit: BoxFit.cover,
                    errorWidget: ColoredBox(
                      color: AppColors.surfaceSecondary,
                      child: Icon(Icons.person_rounded, size: 30),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isProfessional && professional != null
                          ? professional.businessName
                          : '${guest.firstName}, ${guest.age}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isProfessional && professional != null
                          ? '${professional.category.label} · ${professional.headline}'
                          : '${guest.city} - ${context.tr('{count} nights joined', values: {'count': guest.guestAttendanceCount})}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr(
                        'Requested {time}',
                        values: {'time': _elapsed(context, request.createdAt)},
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_RequestMenuAction>(
                tooltip: context.tr('More actions'),
                onSelected: (action) {
                  switch (action) {
                    case _RequestMenuAction.profile:
                      onViewProfile();
                      break;
                    case _RequestMenuAction.block:
                      onBlock();
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _RequestMenuAction.profile,
                    child: ListTile(
                      leading: Icon(Icons.person_outline_rounded),
                      title: Text('View profile'),
                    ),
                  ),
                  PopupMenuItem(
                    value: _RequestMenuAction.block,
                    child: ListTile(
                      leading: Icon(Icons.block_rounded),
                      title: Text('Block user'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              if (isProfessional)
                PullupChip(
                  label:
                      '${request.professionalCategory?.label ?? 'Professional'} application',
                  icon: Icons.work_history_outlined,
                  color: AppColors.success.withValues(alpha: 0.18),
                )
              else
                PullupChip(
                  label: context.tr(
                    'Group of {count}',
                    values: {'count': request.groupSize},
                  ),
                  icon: Icons.group_outlined,
                  color: request.groupSize > 1
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.surfaceSecondary,
                ),
              if (request.guestMenCount > 0)
                PullupChip(
                  label: context.tr(
                    '+{count} men',
                    values: {'count': request.guestMenCount},
                  ),
                  icon: Icons.man_rounded,
                ),
              if (request.guestWomenCount > 0)
                PullupChip(
                  label: context.tr(
                    '+{count} women',
                    values: {'count': request.guestWomenCount},
                  ),
                  icon: Icons.woman_rounded,
                ),
              for (final badge in guest.badges.take(2))
                PullupChip(label: badge.label, icon: Icons.verified_rounded),
              if (isProfessional && professional != null) ...[
                for (final service in professional.services.take(3))
                  PullupChip(label: service),
                PullupChip(
                  label: '${professional.portfolioItems.length} works',
                  icon: Icons.collections_outlined,
                ),
              ] else
                for (final interest in guest.interests.take(2))
                  PullupChip(label: interest),
            ],
          ),
          if (companionProfiles.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryBright.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 38.0 + (companionProfiles.length - 1) * 24,
                    height: 38,
                    child: Stack(
                      children: [
                        for (
                          var index = 0;
                          index < companionProfiles.length;
                          index++
                        )
                          Positioned(
                            left: index * 24,
                            child: _CompanionAvatar(
                              profile: companionProfiles[index],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PULLUP friends in this group',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          companionProfiles
                              .map((profile) => profile.firstName)
                              .join(', '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (request.companionNames.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.group_add_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    context.tr(
                      'Companions: {names}',
                      values: {'names': request.companionNames.join(', ')},
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
          if (request.note.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    size: 19,
                    color: AppColors.primaryBright,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(request.note)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          switch (request.status) {
            RequestStatus.pending => _PendingActions(
              request: request,
              canFit: canFit,
              onApprove: onApprove,
              onDecline: onDecline,
            ),
            RequestStatus.accepted => _AcceptedStatus(
              event: event,
              professional: isProfessional,
              onOpenChat: onOpenChat,
            ),
            RequestStatus.rejected => _DecisionStatus(
              icon: Icons.do_not_disturb_on_outlined,
              title: 'Request declined',
              color: AppColors.danger,
              reason: request.decisionReason,
            ),
            RequestStatus.withdrawn => const _DecisionStatus(
              icon: Icons.undo_rounded,
              title: 'Request withdrawn',
              color: AppColors.textSecondary,
            ),
            RequestStatus.expired => const _DecisionStatus(
              icon: Icons.timer_off_outlined,
              title: 'Request expired',
              color: AppColors.textSecondary,
            ),
          },
        ],
      ),
    );
  }

  static String _elapsed(BuildContext context, DateTime createdAt) {
    final elapsed = DateTime.now().difference(createdAt);
    if (elapsed.inMinutes < 1) return context.tr('just now');
    if (elapsed.inHours < 1) {
      return context.tr(
        '{count} min ago',
        values: {'count': elapsed.inMinutes},
      );
    }
    if (elapsed.inDays < 1) {
      return context.tr('{count}h ago', values: {'count': elapsed.inHours});
    }
    return context.tr('{count}d ago', values: {'count': elapsed.inDays});
  }
}

class _CompanionAvatar extends StatelessWidget {
  const _CompanionAvatar({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final source =
        profile.mainPhotoUrl ??
        (profile.profilePhotos.isEmpty ? '' : profile.profilePhotos.first);
    return Container(
      width: 38,
      height: 38,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      child: ClipOval(child: PullupImage(source: source)),
    );
  }
}

class _PendingActions extends StatelessWidget {
  const _PendingActions({
    required this.request,
    required this.canFit,
    this.onApprove,
    this.onDecline,
  });

  final EventRequest request;
  final bool canFit;
  final VoidCallback? onApprove;
  final VoidCallback? onDecline;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!canFit) ...[
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: AppColors.warning,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'This group no longer fits the available capacity.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.warning),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                key: Key('approve-request-${request.id}'),
                onPressed: canFit ? onApprove : null,
                icon: const Icon(Icons.check_rounded),
                label: Text(
                  request.kind == EventRequestKind.professionalService
                      ? 'Connect'
                      : 'Approve',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                key: Key('decline-request-${request.id}'),
                onPressed: onDecline,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                ),
                icon: const Icon(Icons.close_rounded),
                label: const Text('Decline'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AcceptedStatus extends StatelessWidget {
  const _AcceptedStatus({
    required this.event,
    required this.professional,
    this.onOpenChat,
  });

  final PartyEvent event;
  final bool professional;
  final VoidCallback? onOpenChat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                professional
                    ? Icons.handshake_outlined
                    : Icons.lock_open_rounded,
                size: 19,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              Text(
                professional ? 'Professional connected' : 'Access granted',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            professional
                ? 'A private 12-hour conversation is open to discuss the brief.'
                : event.exactAddress ?? 'Address pending',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (onOpenChat != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onOpenChat,
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: const Text('Open chat'),
            ),
          ],
        ],
      ),
    );
  }
}

class _DecisionStatus extends StatelessWidget {
  const _DecisionStatus({
    required this.icon,
    required this.title,
    required this.color,
    this.reason,
  });

  final IconData icon;
  final String title;
  final Color color;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: color, fontWeight: FontWeight.w800),
              ),
              if (reason != null && reason!.isNotEmpty)
                Text(
                  context.tr(
                    'Reason: {reason}',
                    values: {'reason': context.tr(reason!)},
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _RequestMenuAction { profile, block }
