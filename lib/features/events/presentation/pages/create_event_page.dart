import 'package:pullup/l10n/app_material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/night_card.dart';
import '../../../../core/widgets/number_stepper.dart';
import '../../../../core/widgets/wizard_scaffold.dart';
import '../../../../models/enums.dart';
import '../../../../models/geo_point_lite.dart';
import '../../../shared/domain/app_drafts.dart';

String _demoCoverFor(EventCategory category) => switch (category) {
  EventCategory.rooftop => 'assets/demo/events/rooftop-night.jpg',
  EventCategory.poolParty ||
  EventCategory.villaParty => 'assets/demo/events/villa-pool-party.jpg',
  EventCategory.boatParty => 'assets/demo/events/yacht-sunset.jpg',
  EventCategory.studentParty => 'assets/demo/events/student-apartment.jpg',
  EventCategory.privateDjSet => 'assets/demo/events/private-dj-set.jpg',
  EventCategory.birthday => 'assets/demo/events/birthday-suite.jpg',
  EventCategory.after ||
  EventCategory.otherNightPlan => 'assets/demo/events/pigalle-after.jpg',
  EventCategory.houseParty ||
  EventCategory.preGame ||
  EventCategory.apartmentParty => 'assets/demo/events/apartment-pregame.jpg',
};

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
  DateTime _start = DateTime.now().add(const Duration(hours: 2));
  DateTime _end = DateTime.now().add(const Duration(hours: 6));
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
  int _selectedMediaCount = 0;

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
    final steps = <_CreateStep>[
      _CreateStep(
        title: 'Choose the format',
        description: 'Set the type of night guests will discover first.',
        child: DropdownButtonFormField<EventCategory>(
          initialValue: _category,
          isExpanded: true,
          items: [
            for (final category in EventCategory.values)
              DropdownMenuItem(value: category, child: Text(category.label)),
          ],
          onChanged: (value) => setState(() => _category = value ?? _category),
          decoration: InputDecoration(
            labelText: context.tr('Night plan type'),
            prefixIcon: Icon(Icons.nightlife_outlined),
          ),
        ),
      ),
      _CreateStep(
        title: 'Set the essentials',
        description: 'Give guests the details they need to decide quickly.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.tr('Event title'),
                hintText: context.tr('Last-minute rooftop pre-game'),
                prefixIcon: Icon(Icons.edit_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: context.tr('Description'),
                hintText: context.tr(
                  'Describe the atmosphere, music and guest list.',
                ),
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 12),
            _DateTimeField(
              label: 'Starts',
              value: _start,
              icon: Icons.schedule_rounded,
              onTap: () => _pickDateTime(isStart: true),
            ),
            const SizedBox(height: 12),
            _DateTimeField(
              label: 'Ends',
              value: _end,
              icon: Icons.timelapse_rounded,
              onTap: () => _pickDateTime(isStart: false),
            ),
            const SizedBox(height: 20),
            Text('Guest list', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            NumberStepper(
              label: 'Maximum guests',
              value: _maxParticipants,
              minValue: 2,
              maxValue: 200,
              onChanged: (value) => setState(
                () => _maxParticipants = value.clamp(2, 200).toInt(),
              ),
            ),
            const SizedBox(height: 8),
            NumberStepper(
              label: 'Minimum age',
              value: _ageRequirement,
              minValue: 18,
              maxValue: 60,
              suffix: '+',
              onChanged: (value) =>
                  setState(() => _ageRequirement = value.clamp(18, 60).toInt()),
            ),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              value: _allowsGroups,
              onChanged: (value) => setState(() => _allowsGroups = value),
              title: const Text('Allow group requests'),
              subtitle: const Text('One guest can request several spots.'),
            ),
            if (_allowsGroups) ...[
              const SizedBox(height: 8),
              NumberStepper(
                label: 'Maximum group size',
                value: _maxGroupSize,
                minValue: 1,
                maxValue: 10,
                onChanged: (value) =>
                    setState(() => _maxGroupSize = value.clamp(1, 10).toInt()),
              ),
            ],
          ],
        ),
      ),
      _CreateStep(
        title: 'Place it on the map',
        description:
            'The exact address stays private until you approve a guest.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _city,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.tr('City'),
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _area,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.tr('Area or district'),
                prefixIcon: Icon(Icons.map_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _address,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.fullStreetAddress],
              decoration: InputDecoration(
                labelText: context.tr('Private address'),
                helperText: context.tr('Visible only to accepted guests'),
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _access,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: context.tr('Access instructions'),
                hintText: context.tr(
                  'Entrance, floor, door code or host contact.',
                ),
                prefixIcon: Icon(Icons.directions_outlined),
              ),
            ),
            const SizedBox(height: 16),
            const _PrivacyNotice(),
          ],
        ),
      ),
      _CreateStep(
        title: 'Show the place',
        description: 'Choose a strong cover and a few clear venue photos.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _selectedMediaCount == 0
                          ? Icons.add_photo_alternate_outlined
                          : Icons.photo_library_outlined,
                      size: 42,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedMediaCount == 0
                          ? 'No photos selected'
                          : '$_selectedMediaCount photo${_selectedMediaCount == 1 ? '' : 's'} selected',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Up to 6 images',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _pickMedia,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(
                _selectedMediaCount == 0 ? 'Choose photos' : 'Change photos',
              ),
            ),
          ],
        ),
      ),
      _CreateStep(
        title: 'Define the vibe',
        description: 'Set clear expectations before anyone requests to join.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Atmosphere & rules',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            _TagPicker(selected: _tags),
            const SizedBox(height: 22),
            Text('Music', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            _GenrePicker(selected: _genres),
            const SizedBox(height: 18),
            TextField(
              controller: _dressCode,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.tr('Dress code'),
                prefixIcon: Icon(Icons.checkroom_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contribution,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.tr('What guests should bring'),
                prefixIcon: Icon(Icons.local_bar_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _rules,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: context.tr('House rules'),
                prefixIcon: Icon(Icons.gavel_outlined),
              ),
            ),
          ],
        ),
      ),
      _CreateStep(
        title: 'Review and publish',
        description:
            'Check the public details and choose how requests are handled.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NightCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title.text.trim().isEmpty ? 'Untitled night' : _title.text,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _ReviewRow(
                    icon: Icons.nightlife_outlined,
                    text: _category.label,
                  ),
                  _ReviewRow(
                    icon: Icons.schedule_rounded,
                    text: DateFormat(
                      'EEE d MMM, HH:mm',
                      Localizations.localeOf(context).toLanguageTag(),
                    ).format(_start),
                  ),
                  _ReviewRow(
                    icon: Icons.place_outlined,
                    text: '${_area.text}, ${_city.text}',
                  ),
                  const _ReviewRow(
                    icon: Icons.lock_outline_rounded,
                    text: 'Exact address hidden until approval',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ApprovalMode>(
              initialValue: _approval,
              isExpanded: true,
              items: [
                for (final mode in ApprovalMode.values)
                  DropdownMenuItem(value: mode, child: Text(mode.label)),
              ],
              onChanged: (value) =>
                  setState(() => _approval = value ?? _approval),
              decoration: InputDecoration(
                labelText: context.tr('Request approval'),
                prefixIcon: Icon(Icons.how_to_reg_outlined),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<EventVisibility>(
              initialValue: _visibility,
              isExpanded: true,
              items: [
                for (final visibility in EventVisibility.values)
                  DropdownMenuItem(
                    value: visibility,
                    child: Text(visibility.label),
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _visibility = value ?? _visibility),
              decoration: InputDecoration(
                labelText: context.tr('Visibility'),
                prefixIcon: Icon(Icons.visibility_outlined),
              ),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      body: WizardScaffold(
        eyebrow: 'Create a night plan',
        title: steps[_step].title,
        description: steps[_step].description,
        currentStep: _step,
        stepCount: steps.length,
        continueLabel: _step == steps.length - 1
            ? 'Publish night plan'
            : 'Continue',
        continueIcon: _step == steps.length - 1
            ? Icons.rocket_launch_rounded
            : Icons.arrow_forward_rounded,
        onContinue: _nextOrPublish,
        onBack: _step == 0 ? null : () => setState(() => _step--),
        child: steps[_step].child,
      ),
    );
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final initial = isStart ? _start : _end;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;
    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (isStart) {
        _start = selected;
        if (!_end.isAfter(_start)) {
          _end = _start.add(const Duration(hours: 4));
        }
      } else {
        _end = selected.isAfter(_start)
            ? selected
            : _start.add(const Duration(hours: 1));
      }
    });
  }

  Future<void> _pickMedia() async {
    final files = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (files.isEmpty || !mounted) return;
    setState(() => _selectedMediaCount = files.take(6).length);
  }

  Future<void> _nextOrPublish() async {
    if (_step == 1 &&
        (_title.text.trim().isEmpty || _description.text.trim().isEmpty)) {
      _showMessage('Add a title and description before continuing.');
      return;
    }
    if (_step == 2 &&
        (_city.text.trim().isEmpty ||
            _area.text.trim().isEmpty ||
            _address.text.trim().isEmpty)) {
      _showMessage('Add the city, area and private address to continue.');
      return;
    }
    if (_step < 5) {
      setState(() => _step++);
      return;
    }
    final demoCover = _demoCoverFor(_category);
    await ref
        .read(appControllerProvider.notifier)
        .createEvent(
          CreateEventDraft(
            title: _title.text.trim(),
            description: _description.text.trim(),
            category: _category,
            coverPhotoUrl: demoCover,
            photoUrls: [demoCover],
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CreateStep {
  const _CreateStep({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;
}

class _DateTimeField extends StatelessWidget {
  const _DateTimeField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: context.tr(label),
          prefixIcon: Icon(icon),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                DateFormat(
                  'EEE d MMM, HH:mm',
                  Localizations.localeOf(context).toLanguageTag(),
                ).format(value),
              ),
            ),
            const Icon(
              Icons.expand_more_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyNotice extends StatelessWidget {
  const _PrivacyNotice();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.shield_outlined, color: AppColors.primaryBright),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Guests only see the city, district and approximate distance before approval.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
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
