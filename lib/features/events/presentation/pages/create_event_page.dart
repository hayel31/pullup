import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../models/enums.dart';
import '../../../../models/geo_point_lite.dart';
import '../../../shared/domain/app_drafts.dart';

class CreateEventPage extends ConsumerStatefulWidget {
  const CreateEventPage({super.key});

  @override
  ConsumerState<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends ConsumerState<CreateEventPage> {
  int _step = 0;
  EventCategory _category = EventCategory.houseParty;
  final _title = TextEditingController(text: 'Last-minute rooftop pre-game');
  final _description = TextEditingController(
    text: 'Private guest list, good music, address only after approval.',
  );
  final _city = TextEditingController(text: 'Paris');
  final _area = TextEditingController(text: 'Bastille');
  final _address = TextEditingController(text: '14 Rue Keller, 75011 Paris');
  final _access = TextEditingController(
    text: 'Use the side entrance. Do not share the address.',
  );
  final _dressCode = TextEditingController(text: 'Night casual');
  final _rules = TextEditingController(
    text: 'Respect the address, no public posts, no harassment.',
  );
  final _contribution = TextEditingController(text: 'BYOB appreciated');
  final DateTime _start = DateTime.now().add(const Duration(hours: 2));
  final DateTime _end = DateTime.now().add(const Duration(hours: 6));
  int _maxParticipants = 18;
  int _ageRequirement = 18;
  bool _allowsGroups = true;
  int _maxGroupSize = 3;
  ApprovalMode _approval = ApprovalMode.manual;
  EventVisibility _visibility = EventVisibility.public;
  final _tags = <EventTag>{
    EventTag.byob,
    EventTag.outdoor,
    EventTag.lastMinute,
    EventTag.dancing,
  };
  final _genres = <String>{'House', 'Afro', 'Rap'};

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _city.dispose();
    _area.dispose();
    _address.dispose();
    _access.dispose();
    _dressCode.dispose();
    _rules.dispose();
    _contribution.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stepper(
        currentStep: _step,
        onStepTapped: (value) => setState(() => _step = value),
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              Expanded(
                child: GradientButton(
                  label: _step == 5 ? 'Publish event' : 'Continue',
                  icon: _step == 5
                      ? Icons.rocket_launch_rounded
                      : Icons.arrow_forward_rounded,
                  onPressed: _nextOrPublish,
                ),
              ),
              if (_step > 0)
                IconButton(
                  onPressed: () => setState(() => _step--),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
            ],
          ),
        ),
        steps: [
          Step(
            title: const Text('Type'),
            isActive: _step == 0,
            content: DropdownButtonFormField<EventCategory>(
              initialValue: _category,
              items: [
                for (final category in EventCategory.values)
                  DropdownMenuItem(
                    value: category,
                    child: Text(category.label),
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _category = value ?? _category),
              decoration: const InputDecoration(labelText: 'Party type'),
            ),
          ),
          Step(
            title: const Text('Info'),
            isActive: _step == 1,
            content: Column(
              children: [
                TextField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _description,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                _NumberRow(
                  label: 'Max participants',
                  value: _maxParticipants,
                  onChanged: (value) => setState(
                    () => _maxParticipants = value.clamp(2, 200).toInt(),
                  ),
                ),
                _NumberRow(
                  label: 'Age requirement',
                  value: _ageRequirement,
                  onChanged: (value) => setState(
                    () => _ageRequirement = value.clamp(18, 60).toInt(),
                  ),
                ),
                SwitchListTile(
                  value: _allowsGroups,
                  onChanged: (value) => setState(() => _allowsGroups = value),
                  title: const Text('Groups allowed'),
                ),
                _NumberRow(
                  label: 'Max group size',
                  value: _maxGroupSize,
                  onChanged: (value) => setState(
                    () => _maxGroupSize = value.clamp(1, 10).toInt(),
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Location'),
            isActive: _step == 2,
            content: Column(
              children: [
                TextField(
                  controller: _city,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _area,
                  decoration: const InputDecoration(
                    labelText: 'Area or district',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _address,
                  decoration: const InputDecoration(
                    labelText: 'Exact private address',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _access,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Access instructions',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Only city, area and approximate distance are public before approval.',
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Media'),
            isActive: _step == 3,
            content: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Demo cover photo will be assigned automatically.'),
                SizedBox(height: 8),
                Text(
                  'Firebase Storage upload and compression are prepared behind repository interfaces.',
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Vibe'),
            isActive: _step == 4,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TagPicker(selected: _tags),
                const SizedBox(height: 16),
                _GenrePicker(selected: _genres),
                const SizedBox(height: 12),
                TextField(
                  controller: _dressCode,
                  decoration: const InputDecoration(labelText: 'Dress code'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contribution,
                  decoration: const InputDecoration(labelText: 'Contribution'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _rules,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'House rules'),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Publish'),
            isActive: _step == 5,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title.text,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('${_category.label} - ${_area.text}, ${_city.text}'),
                Text('Address hidden until host approval.'),
                const SizedBox(height: 8),
                DropdownButtonFormField<ApprovalMode>(
                  initialValue: _approval,
                  items: [
                    for (final mode in ApprovalMode.values)
                      DropdownMenuItem(value: mode, child: Text(mode.label)),
                  ],
                  onChanged: (value) =>
                      setState(() => _approval = value ?? _approval),
                  decoration: const InputDecoration(labelText: 'Approval mode'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<EventVisibility>(
                  initialValue: _visibility,
                  items: [
                    for (final visibility in EventVisibility.values)
                      DropdownMenuItem(
                        value: visibility,
                        child: Text(visibility.label),
                      ),
                  ],
                  onChanged: (value) =>
                      setState(() => _visibility = value ?? _visibility),
                  decoration: const InputDecoration(labelText: 'Visibility'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _nextOrPublish() async {
    if (_step < 5) {
      setState(() => _step++);
      return;
    }
    await ref
        .read(appControllerProvider.notifier)
        .createEvent(
          CreateEventDraft(
            title: _title.text.trim(),
            description: _description.text.trim(),
            category: _category,
            coverPhotoUrl:
                'https://picsum.photos/seed/pullup-created/1200/1600',
            photoUrls: const [
              'https://picsum.photos/seed/pullup-created/1200/1600',
              'https://picsum.photos/seed/pullup-created-2/1200/1600',
            ],
            city: _city.text.trim(),
            areaName: _area.text.trim(),
            approximateGeoPoint: const GeoPointLite(
              latitude: 48.8566,
              longitude: 2.3522,
            ),
            exactAddress: _address.text.trim(),
            accessInstructions: _access.text.trim(),
            startDateTime: _start,
            endDateTime: _end,
            timezone: 'Europe/Paris',
            ageRequirement: _ageRequirement,
            maxParticipants: _maxParticipants,
            allowsGroups: _allowsGroups,
            maxGroupSize: _maxGroupSize,
            eventTags: _tags.toList(),
            musicGenres: _genres.toList(),
            dressCode: _dressCode.text.trim(),
            contributionText: _contribution.text.trim(),
            houseRules: _rules.text.trim(),
            alcoholPolicy: _tags.contains(EventTag.noAlcohol)
                ? AlcoholPolicy.notAllowed
                : AlcoholPolicy.byob,
            smokingPolicy: _tags.contains(EventTag.smokeFriendly)
                ? SmokingPolicy.smokeFriendly
                : SmokingPolicy.outdoorOnly,
            visibility: _visibility,
            approvalMode: _approval,
          ),
        );
    if (mounted) context.go('/tonight');
  }
}

class _NumberRow extends StatelessWidget {
  const _NumberRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        IconButton(
          onPressed: () => onChanged(value - 1),
          icon: const Icon(Icons.remove_circle_outline_rounded),
        ),
        Text('$value'),
        IconButton(
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add_circle_outline_rounded),
        ),
      ],
    );
  }
}

class _TagPicker extends StatefulWidget {
  const _TagPicker({required this.selected});

  final Set<EventTag> selected;

  @override
  State<_TagPicker> createState() => _TagPickerState();
}

class _TagPickerState extends State<_TagPicker> {
  @override
  Widget build(BuildContext context) {
    const tags = [
      EventTag.alcoholAllowed,
      EventTag.noAlcohol,
      EventTag.smokeFriendly,
      EventTag.noSmoking,
      EventTag.dj,
      EventTag.pool,
      EventTag.outdoor,
      EventTag.indoor,
      EventTag.byob,
      EventTag.dressCode,
      EventTag.securityPresent,
      EventTag.invitationOnly,
      EventTag.groupsWelcome,
      EventTag.lastMinute,
      EventTag.musicLoud,
      EventTag.chillAtmosphere,
      EventTag.dancing,
      EventTag.photosAllowed,
      EventTag.noPhotos,
      EventTag.djNeeded,
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final tag in tags)
          FilterChip(
            selected: widget.selected.contains(tag),
            label: Text(tag.label),
            onSelected: (_) => setState(() {
              widget.selected.contains(tag)
                  ? widget.selected.remove(tag)
                  : widget.selected.add(tag);
            }),
          ),
      ],
    );
  }
}

class _GenrePicker extends StatefulWidget {
  const _GenrePicker({required this.selected});

  final Set<String> selected;

  @override
  State<_GenrePicker> createState() => _GenrePickerState();
}

class _GenrePickerState extends State<_GenrePicker> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final genre in musicGenreOptions.take(10))
          FilterChip(
            selected: widget.selected.contains(genre),
            label: Text(genre),
            onSelected: (_) => setState(() {
              widget.selected.contains(genre)
                  ? widget.selected.remove(genre)
                  : widget.selected.add(genre);
            }),
          ),
      ],
    );
  }
}
