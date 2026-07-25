import 'dart:convert';
import 'dart:math' as math;

import 'package:pullup/l10n/app_material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/city_location_resolver.dart';
import '../../../../core/widgets/night_card.dart';
import '../../../../core/widgets/number_stepper.dart';
import '../../../../core/widgets/pullup_chip.dart';
import '../../../../core/widgets/pullup_image.dart';
import '../../../../core/widgets/wizard_scaffold.dart';
import '../../../../models/enums.dart';
import '../../../../models/attendance_breakdown.dart';
import '../../../../models/geo_point_lite.dart';
import '../../data/address_search_service.dart';
import '../../../shared/domain/app_drafts.dart';
import '../widgets/event_text_editor.dart';

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
  final _city = TextEditingController(text: 'Toulouse');
  final _area = TextEditingController(text: 'Carmes');
  final _address = TextEditingController(
    text: '12 Rue des Filatiers, Toulouse',
  );
  final _access = TextEditingController(
    text: 'Use the side entrance. Do not share the address.',
  );
  final _dressCode = TextEditingController(text: 'Night casual');
  final _rules = TextEditingController(
    text: 'Respect the address, no public posts, no harassment.',
  );
  final _contribution = TextEditingController();
  DateTime _start = DateTime.now().add(const Duration(hours: 2));
  DateTime _end = DateTime.now().add(const Duration(hours: 6));
  int _maxParticipants = 18;
  int _initialMenCount = 0;
  int _initialWomenCount = 0;
  int _initialOtherCount = 1;
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
  final _professionalNeeds = <ProfessionalCategory>{};
  final List<String> _selectedPhotoSources = [];
  GeoPointLite? _selectedAddressLocation;
  bool _isPickingMedia = false;
  bool _publishAsProfessional = false;
  bool _isPaidEntry = false;
  int _entryFeeEuros = 10;
  AlcoholPolicy _alcoholPolicy = AlcoholPolicy.byob;
  FoodPolicy _foodPolicy = FoodPolicy.noneRequired;

  int get _initialAttendanceTotal =>
      _initialMenCount + _initialWomenCount + _initialOtherCount;

  @override
  void initState() {
    super.initState();
    _publishAsProfessional =
        ref.read(appControllerProvider).currentUser?.isProfessional ?? false;
    final gender = ref.read(appControllerProvider).currentUser?.gender;
    _initialMenCount = gender == Gender.man ? 1 : 0;
    _initialWomenCount = gender == Gender.woman ? 1 : 0;
    _initialOtherCount =
        gender == null ||
            gender == Gender.nonBinary ||
            gender == Gender.other ||
            gender == Gender.preferNotToSay
        ? 1
        : 0;
  }

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
    final currentUser = ref.watch(appControllerProvider).currentUser;
    final professional = currentUser?.professionalProfile;
    final isVenuePublisher =
        _publishAsProfessional && (professional?.isVenue ?? false);
    final steps = <_CreateStep>[
      _CreateStep(
        title: 'Choose the format',
        description: 'Set the type of night guests will discover first.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (professional != null) ...[
              _PublishingIdentitySelector(
                profileName: professional.businessName,
                category: professional.category,
                publishAsProfessional: _publishAsProfessional,
                onChanged: (value) =>
                    setState(() => _publishAsProfessional = value),
              ),
              const SizedBox(height: 16),
            ],
            DropdownButtonFormField<EventCategory>(
              initialValue: _category,
              isExpanded: true,
              items: [
                for (final category in EventCategory.values)
                  DropdownMenuItem(
                    value: category,
                    child: Text(category.label),
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _category = value ?? _category),
              decoration: InputDecoration(
                labelText: context.tr('Night plan type'),
                prefixIcon: const Icon(Icons.nightlife_outlined),
              ),
            ),
          ],
        ),
      ),
      _CreateStep(
        title: 'Set the essentials',
        description: 'Give guests the details they need to decide quickly.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _EditableEventField(
              key: const Key('create-event-title'),
              controller: _title,
              label: context.tr('Event title'),
              hintText: context.tr('Last-minute rooftop pre-game'),
              icon: Icons.edit_outlined,
              onTap: () => _editField(
                controller: _title,
                label: context.tr('Event title'),
                hintText: context.tr('Last-minute rooftop pre-game'),
              ),
            ),
            const SizedBox(height: 12),
            _EditableEventField(
              key: const Key('create-event-description'),
              controller: _description,
              label: context.tr('Description'),
              hintText: context.tr(
                'Describe the atmosphere, music and guest list.',
              ),
              icon: Icons.notes_rounded,
              maxLines: 4,
              onTap: () => _editField(
                controller: _description,
                label: context.tr('Description'),
                hintText: context.tr(
                  'Describe the atmosphere, music and guest list.',
                ),
                multiline: true,
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
              minValue: math.max(2, _initialAttendanceTotal),
              maxValue: 200,
              onChanged: (value) => setState(
                () => _maxParticipants = value.clamp(2, 200).toInt(),
              ),
            ),
            const SizedBox(height: 18),
            _InitialAttendanceEditor(
              menCount: _initialMenCount,
              womenCount: _initialWomenCount,
              otherCount: _initialOtherCount,
              maxParticipants: _maxParticipants,
              onMenChanged: (value) => setState(() => _initialMenCount = value),
              onWomenChanged: (value) =>
                  setState(() => _initialWomenCount = value),
              onOtherChanged: (value) =>
                  setState(() => _initialOtherCount = value),
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
            _EditableEventField(
              key: const Key('create-event-city'),
              controller: _city,
              label: context.tr('City'),
              icon: Icons.location_city_outlined,
              onTap: () => _editField(
                controller: _city,
                label: context.tr('City'),
                onChanged: () => _selectedAddressLocation = null,
              ),
            ),
            const SizedBox(height: 12),
            _EditableEventField(
              key: const Key('create-event-area'),
              controller: _area,
              label: context.tr('Area or district'),
              icon: Icons.map_outlined,
              onTap: () => _editField(
                controller: _area,
                label: context.tr('Area or district'),
              ),
            ),
            const SizedBox(height: 12),
            _EditableEventField(
              key: const Key('create-event-address'),
              controller: _address,
              label: context.tr('Private address'),
              helperText: context.tr('Visible only to accepted guests'),
              icon: Icons.lock_outline_rounded,
              onTap: _editAddress,
            ),
            const SizedBox(height: 12),
            _EditableEventField(
              key: const Key('create-event-access'),
              controller: _access,
              label: context.tr('Access instructions'),
              hintText: context.tr(
                'Entrance, floor, door code or host contact.',
              ),
              icon: Icons.directions_outlined,
              maxLines: 3,
              onTap: () => _editField(
                controller: _access,
                label: context.tr('Access instructions'),
                hintText: context.tr(
                  'Entrance, floor, door code or host contact.',
                ),
                multiline: true,
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
        child: _EventMediaPicker(
          photoSources: _selectedPhotoSources,
          isLoading: _isPickingMedia,
          onPick: _isPickingMedia ? null : _pickMedia,
          onSetCover: _setCoverPhoto,
          onRemove: _removePhoto,
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
            Text(
              context.tr("Entry & what's included"),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 5),
            Text(
              context.tr(
                'Make the price and guest contribution clear before they swipe.',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            _EntryAndSuppliesEditor(
              isPaid: _isPaidEntry,
              entryFeeEuros: _entryFeeEuros,
              alcoholPolicy: _alcoholPolicy,
              foodPolicy: _foodPolicy,
              customContribution: _contribution.text.trim(),
              onPaidChanged: (value) => setState(() => _isPaidEntry = value),
              onEntryFeeChanged: (value) =>
                  setState(() => _entryFeeEuros = value),
              onAlcoholChanged: (value) =>
                  setState(() => _alcoholPolicy = value),
              onFoodChanged: (value) => setState(() => _foodPolicy = value),
            ),
            const SizedBox(height: 12),
            const _SubstanceSafetyNotice(),
            const SizedBox(height: 22),
            Text('Music', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            _GenrePicker(selected: _genres),
            const SizedBox(height: 22),
            Text(
              context.tr('Professionals needed'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 5),
            Text(
              context.tr(
                'Selected professionals can apply with their portfolio.',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            _ProfessionalNeedsPicker(selected: _professionalNeeds),
            const SizedBox(height: 18),
            _EditableEventField(
              key: const Key('create-event-dress-code'),
              controller: _dressCode,
              label: context.tr('Dress code'),
              icon: Icons.checkroom_outlined,
              onTap: () => _editField(
                controller: _dressCode,
                label: context.tr('Dress code'),
              ),
            ),
            const SizedBox(height: 12),
            _EditableEventField(
              key: const Key('create-event-contribution'),
              controller: _contribution,
              label: context.tr('Other contribution (optional)'),
              hintText: context.tr('Ice, soft drinks, a specific snack...'),
              icon: Icons.add_shopping_cart_outlined,
              onTap: () => _editField(
                controller: _contribution,
                label: context.tr('Other contribution (optional)'),
                hintText: context.tr('Ice, soft drinks, a specific snack...'),
              ),
            ),
            const SizedBox(height: 12),
            _EditableEventField(
              key: const Key('create-event-rules'),
              controller: _rules,
              label: context.tr('House rules'),
              icon: Icons.gavel_outlined,
              maxLines: 3,
              onTap: () => _editField(
                controller: _rules,
                label: context.tr('House rules'),
                multiline: true,
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
                  if (_publishAsProfessional && professional != null)
                    _ReviewRow(
                      icon: professional.isVenue
                          ? Icons.storefront_outlined
                          : Icons.workspace_premium_outlined,
                      text: 'Professional event · ${professional.businessName}',
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
                  _ReviewRow(
                    icon: Icons.groups_2_outlined,
                    text: context.tr(
                      '{count} already coming · {spots} open spots',
                      values: {
                        'count': _initialAttendanceTotal,
                        'spots': _maxParticipants - _initialAttendanceTotal,
                      },
                    ),
                  ),
                  _ReviewRow(
                    icon: Icons.payments_outlined,
                    text: _isPaidEntry
                        ? context.tr(
                            '€{amount} entry',
                            values: {'amount': _entryFeeEuros},
                          )
                        : context.tr('Free entry'),
                  ),
                  _ReviewRow(
                    icon: Icons.local_bar_outlined,
                    text: switch (_alcoholPolicy) {
                      AlcoholPolicy.provided => context.tr('Alcohol included'),
                      AlcoholPolicy.byob => context.tr('BYOB required'),
                      AlcoholPolicy.notAllowed => context.tr('No alcohol'),
                      AlcoholPolicy.allowed => context.tr('Alcohol allowed'),
                      AlcoholPolicy.unspecified => context.tr('Not specified'),
                    },
                  ),
                  _ReviewRow(
                    icon: Icons.restaurant_outlined,
                    text: switch (_foodPolicy) {
                      FoodPolicy.provided => context.tr('Food included'),
                      FoodPolicy.bringFood => context.tr('Bring food'),
                      FoodPolicy.noneRequired => context.tr('Nothing required'),
                    },
                  ),
                  _ReviewRow(
                    icon: Icons.health_and_safety_outlined,
                    text: context.tr('Illegal substances prohibited'),
                  ),
                  const _ReviewRow(
                    icon: Icons.lock_outline_rounded,
                    text: 'Exact address hidden until approval',
                  ),
                  if (_professionalNeeds.isNotEmpty)
                    _ReviewRow(
                      icon: Icons.handyman_outlined,
                      text:
                          'Looking for ${_professionalNeeds.map((item) => item.label).join(', ')}',
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (isVenuePublisher)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.blue.withValues(alpha: 0.42),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.favorite_outline_rounded, color: AppColors.blue),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Open venue event: guests show interest instantly. No individual approval is required.',
                      ),
                    ),
                  ],
                ),
              )
            else
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
                  prefixIcon: const Icon(Icons.how_to_reg_outlined),
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
        keyboardOpen: MediaQuery.viewInsetsOf(context).bottom > 0,
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

  Future<void> _editField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    bool multiline = false,
    VoidCallback? onChanged,
  }) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await EventTextEditor.open(
      context,
      label: label,
      initialValue: controller.text,
      hintText: hintText,
      multiline: multiline,
    );
    if (result == null || !mounted) return;
    setState(() {
      controller.text = result.text;
      onChanged?.call();
    });
  }

  Future<void> _editAddress() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await EventTextEditor.open(
      context,
      label: context.tr('Private address'),
      initialValue: _address.text,
      hintText: context.tr('Start typing a street address'),
      keyboardType: TextInputType.streetAddress,
      addressSearchService: ref.read(addressSearchServiceProvider),
      cityHint: _city.text,
    );
    if (result == null || !mounted) return;
    setState(() {
      _address.text = result.text;
      final suggestion = result.address;
      if (suggestion != null) {
        _selectedAddressLocation = suggestion.location;
        if (suggestion.city.isNotEmpty) _city.text = suggestion.city;
      } else {
        _selectedAddressLocation = null;
      }
    });
  }

  Future<void> _pickMedia() async {
    setState(() => _isPickingMedia = true);
    try {
      final files = await ImagePicker().pickMultiImage(
        imageQuality: 70,
        maxWidth: 1280,
        maxHeight: 1280,
      );
      if (files.isEmpty || !mounted) return;

      const maxStoredBytes = 3 * 1024 * 1024;
      var totalBytes = 0;
      var skipped = 0;
      final sources = <String>[];
      for (final file in files.take(6)) {
        final bytes = await file.readAsBytes();
        if (totalBytes + bytes.length > maxStoredBytes) {
          skipped++;
          continue;
        }
        totalBytes += bytes.length;
        final mimeType = file.mimeType ?? _mimeTypeFor(file.name);
        sources.add('data:$mimeType;base64,${base64Encode(bytes)}');
      }
      if (!mounted) return;
      setState(() {
        _selectedPhotoSources
          ..clear()
          ..addAll(sources);
      });
      if (skipped > 0) {
        _showMessage(
          '$skipped photo${skipped == 1 ? '' : 's'} skipped to keep the event fast to load.',
        );
      }
    } catch (_) {
      if (mounted) _showMessage('Photos could not be opened. Try again.');
    } finally {
      if (mounted) setState(() => _isPickingMedia = false);
    }
  }

  void _setCoverPhoto(int index) {
    if (index <= 0 || index >= _selectedPhotoSources.length) return;
    setState(() {
      final source = _selectedPhotoSources.removeAt(index);
      _selectedPhotoSources.insert(0, source);
    });
  }

  void _removePhoto(int index) {
    if (index < 0 || index >= _selectedPhotoSources.length) return;
    setState(() => _selectedPhotoSources.removeAt(index));
  }

  Future<void> _nextOrPublish() async {
    if (_step == 1 &&
        (_title.text.trim().isEmpty || _description.text.trim().isEmpty)) {
      _showMessage('Add a title and description before continuing.');
      return;
    }
    if (_step == 1 &&
        (_initialAttendanceTotal < 1 ||
            _initialAttendanceTotal > _maxParticipants)) {
      _showMessage(
        'Add at least one person already attending and keep the total within capacity.',
      );
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
    final photoSources = _selectedPhotoSources.isEmpty
        ? <String>[demoCover]
        : List<String>.unmodifiable(_selectedPhotoSources);
    final city = _city.text.trim();
    final currentUser = ref.read(appControllerProvider).currentUser;
    final fallbackLocation =
        currentUser?.approximateLocation ??
        const GeoPointLite(latitude: 43.6047, longitude: 1.4442);
    final eventLocation =
        _selectedAddressLocation ??
        CityLocationResolver.resolve(city, fallback: fallbackLocation);
    final eventTags = {..._tags}
      ..removeAll({
        EventTag.alcoholAllowed,
        EventTag.noAlcohol,
        EventTag.byob,
        EventTag.bringFood,
      });
    switch (_alcoholPolicy) {
      case AlcoholPolicy.provided:
      case AlcoholPolicy.allowed:
        eventTags.add(EventTag.alcoholAllowed);
        break;
      case AlcoholPolicy.notAllowed:
        eventTags.add(EventTag.noAlcohol);
        break;
      case AlcoholPolicy.byob:
        eventTags
          ..add(EventTag.alcoholAllowed)
          ..add(EventTag.byob);
        break;
      case AlcoholPolicy.unspecified:
        break;
    }
    if (_foodPolicy == FoodPolicy.bringFood) {
      eventTags.add(EventTag.bringFood);
    }
    await ref
        .read(appControllerProvider.notifier)
        .createEvent(
          CreateEventDraft(
            title: _title.text.trim(),
            description: _description.text.trim(),
            category: _category,
            coverPhotoUrl: photoSources.first,
            photoUrls: photoSources,
            city: city,
            areaName: _area.text.trim(),
            approximateGeoPoint: eventLocation,
            exactAddress: _address.text.trim(),
            accessInstructions: _access.text.trim(),
            startDateTime: _start,
            endDateTime: _end,
            timezone: CityLocationResolver.timezoneFor(city),
            ageRequirement: _ageRequirement,
            maxParticipants: _maxParticipants,
            allowsGroups: _allowsGroups,
            maxGroupSize: _maxGroupSize,
            eventTags: eventTags.toList(),
            musicGenres: _genres.toList(),
            dressCode: _dressCode.text.trim(),
            contributionText: _contribution.text.trim(),
            houseRules: _rules.text.trim(),
            alcoholPolicy: _alcoholPolicy,
            smokingPolicy: _tags.contains(EventTag.smokeFriendly)
                ? SmokingPolicy.smokeFriendly
                : SmokingPolicy.outdoorOnly,
            visibility: _visibility,
            approvalMode: _approval,
            publishAsProfessional: _publishAsProfessional,
            professionalNeeds: _professionalNeeds.toList(),
            attendance: AttendanceBreakdown.initial(
              men: _initialMenCount,
              women: _initialWomenCount,
              other: _initialOtherCount,
            ),
            entryFeeCents: _isPaidEntry ? _entryFeeEuros * 100 : 0,
            foodPolicy: _foodPolicy,
          ),
        );
    if (mounted) context.go('/host');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static String _mimeTypeFor(String fileName) {
    final lowerName = fileName.toLowerCase();
    if (lowerName.endsWith('.png')) return 'image/png';
    if (lowerName.endsWith('.webp')) return 'image/webp';
    if (lowerName.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
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

class _EditableEventField extends StatelessWidget {
  const _EditableEventField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onTap,
    this.hintText,
    this.helperText,
    this.maxLines = 1,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? hintText;
  final String? helperText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      showCursor: false,
      enableInteractiveSelection: false,
      maxLines: maxLines,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        helperText: helperText,
        prefixIcon: Icon(icon),
        suffixIcon: const Icon(Icons.open_in_full_rounded, size: 19),
      ),
    );
  }
}

class _EventMediaPicker extends StatelessWidget {
  const _EventMediaPicker({
    required this.photoSources,
    required this.isLoading,
    required this.onPick,
    required this.onSetCover,
    required this.onRemove,
  });

  final List<String> photoSources;
  final bool isLoading;
  final VoidCallback? onPick;
  final ValueChanged<int> onSetCover;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final hasPhotos = photoSources.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasPhotos)
                  PullupImage(source: photoSources.first)
                else
                  ColoredBox(color: AppColors.surfaceSecondary),
                if (!hasPhotos)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 42,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          context.tr('Add venue photos'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr('The first image becomes the cover'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                if (hasPhotos)
                  Positioned(
                    left: 10,
                    top: 10,
                    child: PullupChip(
                      label: context.tr('Cover photo'),
                      icon: Icons.star_rounded,
                    ),
                  ),
                if (isLoading)
                  ColoredBox(
                    color: AppColors.background.withValues(alpha: 0.72),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
        if (hasPhotos) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photoSources.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) => _PhotoThumbnail(
                source: photoSources[index],
                isCover: index == 0,
                onTap: () => onSetCover(index),
                onRemove: () => onRemove(index),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('Tap a photo to make it the cover. Up to 6 images.'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: onPick,
          icon: isLoading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.photo_library_outlined),
          label: Text(
            context.tr(hasPhotos ? 'Replace photos' : 'Choose photos'),
          ),
        ),
      ],
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail({
    required this.source,
    required this.isCover,
    required this.onTap,
    required this.onRemove,
  });

  final String source;
  final bool isCover;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 76,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Material(
              color: AppColors.surfaceSecondary,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isCover ? AppColors.magenta : AppColors.border,
                  width: isCover ? 2 : 1,
                ),
              ),
              child: InkWell(
                onTap: onTap,
                child: PullupImage(source: source),
              ),
            ),
          ),
          Positioned(
            right: -4,
            top: -4,
            child: IconButton.filled(
              constraints: const BoxConstraints.tightFor(width: 28, height: 28),
              padding: EdgeInsets.zero,
              tooltip: context.tr('Remove photo'),
              onPressed: onRemove,
              iconSize: 16,
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ],
      ),
    );
  }
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
        Icon(Icons.shield_outlined, color: AppColors.primaryBright),
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

class _InitialAttendanceEditor extends StatelessWidget {
  const _InitialAttendanceEditor({
    required this.menCount,
    required this.womenCount,
    required this.otherCount,
    required this.maxParticipants,
    required this.onMenChanged,
    required this.onWomenChanged,
    required this.onOtherChanged,
  });

  final int menCount;
  final int womenCount;
  final int otherCount;
  final int maxParticipants;
  final ValueChanged<int> onMenChanged;
  final ValueChanged<int> onWomenChanged;
  final ValueChanged<int> onOtherChanged;

  int get total => menCount + womenCount + otherCount;

  @override
  Widget build(BuildContext context) {
    final openSpots = math.max(0, maxParticipants - total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.groups_2_outlined, color: AppColors.primaryBright),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                context.tr('Who is already coming?'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          context.tr(
            'Include yourself and everyone confirmed before publication.',
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        NumberStepper(
          label: context.tr('Men already coming'),
          value: menCount,
          minValue: 0,
          maxValue: maxParticipants - womenCount - otherCount,
          onChanged: onMenChanged,
        ),
        const SizedBox(height: 8),
        NumberStepper(
          label: context.tr('Women already coming'),
          value: womenCount,
          minValue: 0,
          maxValue: maxParticipants - menCount - otherCount,
          onChanged: onWomenChanged,
        ),
        const SizedBox(height: 8),
        NumberStepper(
          label: context.tr('Other / not specified'),
          value: otherCount,
          minValue: 0,
          maxValue: maxParticipants - menCount - womenCount,
          onChanged: onOtherChanged,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.primaryBright.withValues(alpha: 0.34),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _AttendanceSummaryMetric(
                  value: '$total',
                  label: context.tr('Already coming'),
                  color: AppColors.primaryBright,
                ),
              ),
              Container(width: 1, height: 34, color: AppColors.border),
              Expanded(
                child: _AttendanceSummaryMetric(
                  value: '$openSpots',
                  label: context.tr('Open spots'),
                  color: AppColors.success,
                ),
              ),
              Container(width: 1, height: 34, color: AppColors.border),
              Expanded(
                child: _AttendanceSummaryMetric(
                  value: '♂ $menCount · ♀ $womenCount',
                  label: context.tr('Current mix'),
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttendanceSummaryMetric extends StatelessWidget {
  const _AttendanceSummaryMetric({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _EntryAndSuppliesEditor extends StatelessWidget {
  const _EntryAndSuppliesEditor({
    required this.isPaid,
    required this.entryFeeEuros,
    required this.alcoholPolicy,
    required this.foodPolicy,
    required this.customContribution,
    required this.onPaidChanged,
    required this.onEntryFeeChanged,
    required this.onAlcoholChanged,
    required this.onFoodChanged,
  });

  final bool isPaid;
  final int entryFeeEuros;
  final AlcoholPolicy alcoholPolicy;
  final FoodPolicy foodPolicy;
  final String customContribution;
  final ValueChanged<bool> onPaidChanged;
  final ValueChanged<int> onEntryFeeChanged;
  final ValueChanged<AlcoholPolicy> onAlcoholChanged;
  final ValueChanged<FoodPolicy> onFoodChanged;

  @override
  Widget build(BuildContext context) {
    final requiredItems = <String>[
      if (alcoholPolicy == AlcoholPolicy.byob) context.tr('drinks'),
      if (foodPolicy == FoodPolicy.bringFood) context.tr('food'),
      if (customContribution.isNotEmpty) customContribution,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(
              value: false,
              icon: const Icon(Icons.money_off_rounded),
              label: Text(context.tr('Free entry')),
            ),
            ButtonSegment(
              value: true,
              icon: const Icon(Icons.payments_outlined),
              label: Text(context.tr('Paid entry')),
            ),
          ],
          selected: {isPaid},
          onSelectionChanged: (selection) =>
              onPaidChanged(selection.firstOrNull ?? false),
        ),
        if (isPaid) ...[
          const SizedBox(height: 10),
          NumberStepper(
            key: const Key('create-event-entry-fee'),
            label: context.tr('Entry price'),
            value: entryFeeEuros,
            minValue: 1,
            maxValue: 100,
            suffix: ' €',
            onChanged: onEntryFeeChanged,
          ),
        ],
        const SizedBox(height: 16),
        Text(
          context.tr('Drinks'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PolicyChoice<AlcoholPolicy>(
              value: AlcoholPolicy.provided,
              selectedValue: alcoholPolicy,
              label: '🍸 ${context.tr('Provided')}',
              onSelected: onAlcoholChanged,
            ),
            _PolicyChoice<AlcoholPolicy>(
              value: AlcoholPolicy.byob,
              selectedValue: alcoholPolicy,
              label: '🥂 ${context.tr('Bring your own')}',
              onSelected: onAlcoholChanged,
            ),
            _PolicyChoice<AlcoholPolicy>(
              value: AlcoholPolicy.notAllowed,
              selectedValue: alcoholPolicy,
              label: '🚫🍸 ${context.tr('No alcohol')}',
              onSelected: onAlcoholChanged,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(context.tr('Food'), style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PolicyChoice<FoodPolicy>(
              value: FoodPolicy.provided,
              selectedValue: foodPolicy,
              label: '🍕 ${context.tr('Provided')}',
              onSelected: onFoodChanged,
            ),
            _PolicyChoice<FoodPolicy>(
              value: FoodPolicy.bringFood,
              selectedValue: foodPolicy,
              label: '🥡 ${context.tr('Bring food')}',
              onSelected: onFoodChanged,
            ),
            _PolicyChoice<FoodPolicy>(
              value: FoodPolicy.noneRequired,
              selectedValue: foodPolicy,
              label: '✓ ${context.tr('Nothing required')}',
              onSelected: onFoodChanged,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: requiredItems.isEmpty
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  (requiredItems.isEmpty
                          ? AppColors.success
                          : AppColors.warning)
                      .withValues(alpha: 0.36),
            ),
          ),
          child: Row(
            children: [
              Icon(
                requiredItems.isEmpty
                    ? Icons.check_circle_outline_rounded
                    : Icons.shopping_bag_outlined,
                color: requiredItems.isEmpty
                    ? AppColors.success
                    : AppColors.warning,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  requiredItems.isEmpty
                      ? context.tr('Guests do not need to bring anything.')
                      : context.tr(
                          'Guests should bring: {items}.',
                          values: {'items': requiredItems.join(' + ')},
                        ),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PolicyChoice<T> extends StatelessWidget {
  const _PolicyChoice({
    required this.value,
    required this.selectedValue,
    required this.label,
    required this.onSelected,
  });

  final T value;
  final T selectedValue;
  final String label;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: value == selectedValue,
      label: Text(label),
      onSelected: (_) => onSelected(value),
    );
  }
}

class _SubstanceSafetyNotice extends StatelessWidget {
  const _SubstanceSafetyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🚫💊', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('Illegal substances prohibited'),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: AppColors.danger),
                ),
                const SizedBox(height: 3),
                Text(
                  context.tr(
                    'This safety rule applies to every PULLUP event and cannot be disabled.',
                  ),
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

class _PublishingIdentitySelector extends StatelessWidget {
  const _PublishingIdentitySelector({
    required this.profileName,
    required this.category,
    required this.publishAsProfessional,
    required this.onChanged,
  });

  final String profileName;
  final ProfessionalCategory category;
  final bool publishAsProfessional;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: publishAsProfessional
            ? AppColors.blue.withValues(alpha: 0.12)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: publishAsProfessional
              ? AppColors.blue.withValues(alpha: 0.52)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            category == ProfessionalCategory.bar ||
                    category == ProfessionalCategory.venue
                ? Icons.storefront_outlined
                : Icons.workspace_premium_outlined,
            color: publishAsProfessional
                ? AppColors.blue
                : AppColors.textSecondary,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  publishAsProfessional ? profileName : context.tr('Personal'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  publishAsProfessional
                      ? '${category.label} · professional event'
                      : context.tr('Publish as a private host'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(value: publishAsProfessional, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ProfessionalNeedsPicker extends StatefulWidget {
  const _ProfessionalNeedsPicker({required this.selected});

  final Set<ProfessionalCategory> selected;

  @override
  State<_ProfessionalNeedsPicker> createState() =>
      _ProfessionalNeedsPickerState();
}

class _ProfessionalNeedsPickerState extends State<_ProfessionalNeedsPicker> {
  static const _categories = [
    ProfessionalCategory.dj,
    ProfessionalCategory.photographer,
    ProfessionalCategory.videographer,
    ProfessionalCategory.bartender,
    ProfessionalCategory.security,
    ProfessionalCategory.promoter,
    ProfessionalCategory.eventPlanner,
    ProfessionalCategory.other,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final category in _categories)
          FilterChip(
            avatar: Icon(_iconFor(category), size: 17),
            selected: widget.selected.contains(category),
            label: Text(category.label),
            onSelected: (_) => setState(() {
              widget.selected.contains(category)
                  ? widget.selected.remove(category)
                  : widget.selected.add(category);
            }),
          ),
      ],
    );
  }

  IconData _iconFor(ProfessionalCategory category) => switch (category) {
    ProfessionalCategory.dj => Icons.graphic_eq_rounded,
    ProfessionalCategory.photographer => Icons.photo_camera_outlined,
    ProfessionalCategory.videographer => Icons.videocam_outlined,
    ProfessionalCategory.bartender => Icons.local_bar_outlined,
    ProfessionalCategory.security => Icons.security_outlined,
    ProfessionalCategory.promoter => Icons.campaign_outlined,
    ProfessionalCategory.eventPlanner => Icons.event_note_outlined,
    _ => Icons.handyman_outlined,
  };
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
      EventTag.smokeFriendly,
      EventTag.noSmoking,
      EventTag.dj,
      EventTag.pool,
      EventTag.outdoor,
      EventTag.indoor,
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
