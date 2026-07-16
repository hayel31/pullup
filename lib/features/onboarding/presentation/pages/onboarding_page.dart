import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../../app/providers/app_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/pullup_chip.dart';
import '../../../../models/enums.dart';
import '../../../shared/domain/app_drafts.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  int _step = 0;
  final _bio = TextEditingController(
    text: 'Good music, clean energy, last-minute plans.',
  );
  final _occupation = TextEditingController(text: 'Design student');
  final _instagram = TextEditingController(text: '@pullup.demo');
  final _city = TextEditingController(text: AppConstants.demoCity);
  final _photos = <String>[
    'https://picsum.photos/seed/pullup-onboarding-1/900/1200',
  ];
  final _interests = <String>{'Rooftops', 'Afters', 'Pool parties'};
  final _genres = <String>{'House', 'Afro', 'Rap'};
  final _languages = <String>{'French', 'English'};
  double _distance = 25;
  bool _joinNow = true;
  bool _smallGroups = true;

  @override
  void dispose() {
    _bio.dispose();
    _occupation.dispose();
    _instagram.dispose();
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Set up PULLUP')),
      body: SafeArea(
        child: Stepper(
          currentStep: _step,
          onStepTapped: (step) => setState(() => _step = step),
          controlsBuilder: (context, details) => Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                Expanded(
                  child: GradientButton(
                    label: _step == 3 ? 'Enter PULLUP' : 'Continue',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _nextOrSubmit,
                  ),
                ),
                if (_step > 0) ...[
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () => setState(() => _step--),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ],
              ],
            ),
          ),
          steps: [
            Step(
              title: const Text('Photos'),
              isActive: _step == 0,
              content: _PhotosStep(
                photos: _photos,
                onAdd: _addPhoto,
                onRemove: _removePhoto,
              ),
            ),
            Step(
              title: const Text('Profile'),
              isActive: _step == 1,
              content: _ProfileStep(
                bio: _bio,
                occupation: _occupation,
                instagram: _instagram,
                city: _city,
                interests: _interests,
                genres: _genres,
                languages: _languages,
                onToggleInterest: _toggleInterest,
                onToggleGenre: _toggleGenre,
              ),
            ),
            Step(
              title: const Text('Preferences'),
              isActive: _step == 2,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Distance: ${_distance.round()} km'),
                  Slider(
                    min: 5,
                    max: 80,
                    value: _distance,
                    onChanged: (value) => setState(() => _distance = value),
                  ),
                  SwitchListTile(
                    value: _joinNow,
                    onChanged: (value) => setState(() => _joinNow = value),
                    title: const Text('Available to pull up immediately'),
                  ),
                  SwitchListTile(
                    value: _smallGroups,
                    onChanged: (value) => setState(() => _smallGroups = value),
                    title: const Text('Prefer small groups'),
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Safety'),
              isActive: _step == 3,
              content: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Rule('Respect every user and every address.'),
                  _Rule('Never share a private address publicly.'),
                  _Rule(
                    'No harassment, violence, illegal content or underage use.',
                  ),
                  _Rule('Report or block any unsafe interaction immediately.'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: state.errorMessage == null
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
    );
  }

  Future<void> _addPhoto() async {
    if (_photos.length >= AppConstants.maxProfilePhotos) return;
    await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _photos.add(
        'https://picsum.photos/seed/pullup-onboarding-${_photos.length + 1}/900/1200',
      );
    });
  }

  void _removePhoto(String url) => setState(() => _photos.remove(url));

  void _toggleInterest(String value) => setState(() {
    _interests.contains(value)
        ? _interests.remove(value)
        : _interests.add(value);
  });

  void _toggleGenre(String value) => setState(() {
    _genres.contains(value) ? _genres.remove(value) : _genres.add(value);
  });

  void _nextOrSubmit() {
    if (_step < 3) {
      if (_step == 0 && _photos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add at least one photo.')),
        );
        return;
      }
      setState(() => _step++);
      return;
    }
    final user = ref.read(appControllerProvider).currentUser;
    if (user == null) return;
    ref
        .read(appControllerProvider.notifier)
        .completeOnboarding(
          ProfileUpdateDraft(
            displayName: user.displayName,
            bio: _bio.text.trim(),
            city: _city.text.trim(),
            interests: _interests.toList(),
            musicPreferences: _genres.toList(),
            languages: _languages.toList(),
            profilePhotos: _photos,
            occupation: _occupation.text.trim(),
            instagramHandle: _instagram.text.trim(),
          ),
        );
  }
}

class _PhotosStep extends StatelessWidget {
  const _PhotosStep({
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> photos;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final photo in photos)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  photo,
                  width: 90,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 2,
                top: 2,
                child: IconButton.filledTonal(
                  onPressed: () => onRemove(photo),
                  icon: const Icon(Icons.close_rounded, size: 16),
                ),
              ),
            ],
          ),
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onAdd,
          child: Container(
            width: 90,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(Icons.add_a_photo_rounded),
          ),
        ),
      ],
    );
  }
}

class _ProfileStep extends StatelessWidget {
  const _ProfileStep({
    required this.bio,
    required this.occupation,
    required this.instagram,
    required this.city,
    required this.interests,
    required this.genres,
    required this.languages,
    required this.onToggleInterest,
    required this.onToggleGenre,
  });

  final TextEditingController bio;
  final TextEditingController occupation;
  final TextEditingController instagram;
  final TextEditingController city;
  final Set<String> interests;
  final Set<String> genres;
  final Set<String> languages;
  final ValueChanged<String> onToggleInterest;
  final ValueChanged<String> onToggleGenre;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: bio,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Bio'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: city,
          decoration: const InputDecoration(labelText: 'City'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: occupation,
          decoration: const InputDecoration(labelText: 'Work or studies'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: instagram,
          decoration: const InputDecoration(labelText: 'Instagram optional'),
        ),
        const SizedBox(height: 16),
        _ChipPicker(
          title: 'Night interests',
          values: const [
            'House',
            'Afro',
            'Rap',
            'Cocktails',
            'Rooftops',
            'Pool parties',
            'Afters',
          ],
          selected: interests,
          onToggle: onToggleInterest,
        ),
        const SizedBox(height: 16),
        _ChipPicker(
          title: 'Music',
          values: musicGenreOptions.take(9).toList(),
          selected: genres,
          onToggle: onToggleGenre,
        ),
      ],
    );
  }
}

class _ChipPicker extends StatelessWidget {
  const _ChipPicker({
    required this.title,
    required this.values,
    required this.selected,
    required this.onToggle,
  });

  final String title;
  final List<String> values;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in values)
              FilterChip(
                selected: selected.contains(value),
                label: Text(value),
                onSelected: (_) => onToggle(value),
              ),
          ],
        ),
      ],
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PullupChip(label: text, icon: Icons.shield_outlined),
    );
  }
}
