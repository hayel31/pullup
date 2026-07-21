import 'package:pullup/l10n/app_material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../../app/providers/app_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/pullup_logo.dart';
import '../../../../core/widgets/wizard_scaffold.dart';
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
    final steps = <_OnboardingStep>[
      _OnboardingStep(
        title: 'Lead with a clear photo',
        description:
            'Add up to six photos. Your first image is your main photo.',
        child: _PhotosStep(
          photos: _photos,
          onAdd: _addPhoto,
          onRemove: _removePhoto,
        ),
      ),
      _OnboardingStep(
        title: 'Make your profile useful',
        description:
            'Share enough context for hosts to know who is requesting.',
        child: _ProfileStep(
          bio: _bio,
          occupation: _occupation,
          instagram: _instagram,
          city: _city,
          interests: _interests,
          genres: _genres,
          languages: _languages,
          onToggleInterest: _toggleInterest,
          onToggleGenre: _toggleGenre,
          onToggleLanguage: _toggleLanguage,
        ),
      ),
      _OnboardingStep(
        title: 'Tune your discovery',
        description: 'Set the radius and group style that fit your nights.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Search radius',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${_distance.round()} km',
                  style: TextStyle(
                    color: AppColors.primaryBright,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Slider(
              min: 5,
              max: 80,
              divisions: 15,
              label: '${_distance.round()} km',
              value: _distance,
              onChanged: (value) => setState(() => _distance = value),
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              value: _joinNow,
              onChanged: (value) => setState(() => _joinNow = value),
              title: const Text('Available for last-minute plans'),
              subtitle: const Text('Prioritize nights starting soon.'),
            ),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              value: _smallGroups,
              onChanged: (value) => setState(() => _smallGroups = value),
              title: const Text('Prefer smaller groups'),
              subtitle: const Text('Favor more intimate guest lists.'),
            ),
          ],
        ),
      ),
      const _OnboardingStep(
        title: 'Keep every night safe',
        description: 'These rules protect guests, hosts and private spaces.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Rule('Respect every person and every private space.'),
            _Rule('Never share a private address publicly.'),
            _Rule('Harassment, violence and illegal activity are prohibited.'),
            _Rule('PULLUP is for adults aged 18 and over.'),
            _Rule('Report or block any unsafe interaction immediately.'),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const PullupBrand(logoSize: 28)),
      body: WizardScaffold(
        keyboardOpen: MediaQuery.viewInsetsOf(context).bottom > 0,
        eyebrow: 'Set up your profile',
        title: steps[_step].title,
        description: steps[_step].description,
        currentStep: _step,
        stepCount: steps.length,
        continueLabel: _step == steps.length - 1 ? 'Enter PULLUP' : 'Continue',
        continueIcon: _step == steps.length - 1
            ? Icons.check_rounded
            : Icons.arrow_forward_rounded,
        onContinue: state.loading ? null : _nextOrSubmit,
        onBack: _step == 0 ? null : () => setState(() => _step--),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            steps[_step].child,
            if (state.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: const TextStyle(color: AppColors.danger),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _addPhoto() async {
    if (_photos.length >= AppConstants.maxProfilePhotos) return;
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;
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

  void _toggleLanguage(String value) => setState(() {
    _languages.contains(value)
        ? _languages.remove(value)
        : _languages.add(value);
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

class _OnboardingStep {
  const _OnboardingStep({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;
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
    final count = photos.length < AppConstants.maxProfilePhotos
        ? photos.length + 1
        : photos.length;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.74,
      ),
      itemBuilder: (context, index) {
        if (index == photos.length) {
          return Semantics(
            button: true,
            label: context.tr('Add profile photo'),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onAdd,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined),
                    SizedBox(height: 8),
                    Text(
                      'Add photo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
        final photo = photos[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                photo,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : ColoredBox(
                        color: AppColors.surfaceSecondary,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                errorBuilder: (_, _, _) => ColoredBox(
                  color: AppColors.surfaceSecondary,
                  child: Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
            if (index == 0)
              Positioned(
                left: 6,
                bottom: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.all(Radius.circular(99)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'MAIN',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 4,
              top: 4,
              child: IconButton.filled(
                tooltip: context.tr('Remove photo'),
                style: IconButton.styleFrom(
                  minimumSize: const Size(36, 36),
                  backgroundColor: Colors.black.withValues(alpha: 0.64),
                ),
                onPressed: () => onRemove(photo),
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ),
          ],
        );
      },
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
    required this.onToggleLanguage,
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
  final ValueChanged<String> onToggleLanguage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: bio,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: context.tr('Bio'),
            hintText: context.tr('What should a host know about you?'),
            prefixIcon: Icon(Icons.notes_rounded),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: city,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: context.tr('City'),
            prefixIcon: Icon(Icons.location_city_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: occupation,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: context.tr('Work or studies'),
            helperText: context.tr('Optional'),
            prefixIcon: Icon(Icons.work_outline_rounded),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: instagram,
          decoration: InputDecoration(
            labelText: context.tr('Instagram'),
            helperText: context.tr('Optional'),
            prefixIcon: Icon(Icons.alternate_email_rounded),
          ),
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
        const SizedBox(height: 16),
        _ChipPicker(
          title: 'Languages',
          values: const ['French', 'English', 'Spanish', 'Arabic', 'Italian'],
          selected: languages,
          onToggle: onToggleLanguage,
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, size: 20, color: AppColors.primaryBright),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
