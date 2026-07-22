import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:pullup/l10n/app_material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/pullup_image.dart';
import '../../../../models/enums.dart';
import '../../../../models/professional_profile.dart';

class ProfessionalProfileFormController extends ChangeNotifier {
  ProfessionalProfileFormController({
    required ProfessionalCategory initialCategory,
    ProfessionalProfile? initialProfile,
  }) : category = initialProfile?.category ?? initialCategory,
       businessName = TextEditingController(
         text: initialProfile?.businessName ?? '',
       ),
       headline = TextEditingController(text: initialProfile?.headline ?? ''),
       description = TextEditingController(
         text: initialProfile?.description ?? '',
       ),
       website = TextEditingController(text: initialProfile?.website ?? ''),
       instagram = TextEditingController(
         text: initialProfile?.socialLinks['Instagram'] ?? '',
       ),
       tiktok = TextEditingController(
         text: initialProfile?.socialLinks['TikTok'] ?? '',
       ),
       soundCloud = TextEditingController(
         text: initialProfile?.socialLinks['SoundCloud'] ?? '',
       ),
       spotify = TextEditingController(
         text: initialProfile?.socialLinks['Spotify'] ?? '',
       ),
       indicativeRate = TextEditingController(
         text: initialProfile?.indicativeRate ?? '',
       ),
       availability = TextEditingController(
         text: initialProfile?.availability ?? '',
       ),
       completedProjects = TextEditingController(
         text: initialProfile?.completedProjects.join('\n') ?? '',
       ),
       establishments = TextEditingController(
         text: initialProfile?.establishments.join('\n') ?? '',
       ),
       videoLink = TextEditingController(
         text: _firstMedia(initialProfile, PortfolioMediaType.video),
       ),
       audioLink = TextEditingController(
         text: _firstMedia(initialProfile, PortfolioMediaType.audio),
       ),
       services = {...?initialProfile?.services},
       photoItems = [
         ...?initialProfile?.portfolioItems.where(
           (item) => item.type == PortfolioMediaType.image,
         ),
       ],
       travelRadiusKm = initialProfile?.travelRadiusKm ?? 30,
       yearsExperience = initialProfile?.yearsExperience ?? 1,
       wasVerified = initialProfile?.isVerified ?? false;

  ProfessionalCategory category;
  final TextEditingController businessName;
  final TextEditingController headline;
  final TextEditingController description;
  final TextEditingController website;
  final TextEditingController instagram;
  final TextEditingController tiktok;
  final TextEditingController soundCloud;
  final TextEditingController spotify;
  final TextEditingController indicativeRate;
  final TextEditingController availability;
  final TextEditingController completedProjects;
  final TextEditingController establishments;
  final TextEditingController videoLink;
  final TextEditingController audioLink;
  final Set<String> services;
  final List<ProfessionalPortfolioItem> photoItems;
  double travelRadiusKm;
  int yearsExperience;
  final bool wasVerified;

  bool get isValid =>
      businessName.text.trim().isNotEmpty &&
      headline.text.trim().isNotEmpty &&
      services.isNotEmpty;

  void updateCategory(ProfessionalCategory value) {
    category = value;
    notifyListeners();
  }

  void toggleService(String value) {
    services.contains(value) ? services.remove(value) : services.add(value);
    notifyListeners();
  }

  void updateRadius(double value) {
    travelRadiusKm = value;
    notifyListeners();
  }

  void updateExperience(int value) {
    yearsExperience = value;
    notifyListeners();
  }

  void addPhoto(ProfessionalPortfolioItem item) {
    if (photoItems.length >= 6) return;
    photoItems.add(item);
    notifyListeners();
  }

  void removePhoto(String id) {
    photoItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  ProfessionalProfile buildProfile() {
    final socialLinks = <String, String>{
      if (instagram.text.trim().isNotEmpty) 'Instagram': instagram.text.trim(),
      if (tiktok.text.trim().isNotEmpty) 'TikTok': tiktok.text.trim(),
      if (soundCloud.text.trim().isNotEmpty)
        'SoundCloud': soundCloud.text.trim(),
      if (spotify.text.trim().isNotEmpty) 'Spotify': spotify.text.trim(),
    };
    final portfolio = <ProfessionalPortfolioItem>[
      ...photoItems,
      if (videoLink.text.trim().isNotEmpty)
        ProfessionalPortfolioItem(
          id: 'video-${videoLink.text.hashCode.abs()}',
          title: 'Video showreel',
          url: videoLink.text.trim(),
          type: PortfolioMediaType.video,
        ),
      if (audioLink.text.trim().isNotEmpty)
        ProfessionalPortfolioItem(
          id: 'audio-${audioLink.text.hashCode.abs()}',
          title: 'Audio or music sample',
          url: audioLink.text.trim(),
          type: PortfolioMediaType.audio,
        ),
    ];
    return ProfessionalProfile(
      category: category,
      businessName: businessName.text.trim(),
      headline: headline.text.trim(),
      description: description.text.trim(),
      services: services.toList(),
      portfolioItems: portfolio,
      completedProjects: _lines(completedProjects.text),
      establishments: _lines(establishments.text),
      socialLinks: socialLinks,
      website: website.text.trim().isEmpty ? null : website.text.trim(),
      travelRadiusKm: travelRadiusKm,
      indicativeRate: indicativeRate.text.trim().isEmpty
          ? null
          : indicativeRate.text.trim(),
      availability: availability.text.trim(),
      yearsExperience: yearsExperience,
      isVerified: wasVerified,
    );
  }

  @override
  void dispose() {
    for (final controller in [
      businessName,
      headline,
      description,
      website,
      instagram,
      tiktok,
      soundCloud,
      spotify,
      indicativeRate,
      availability,
      completedProjects,
      establishments,
      videoLink,
      audioLink,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  static String _firstMedia(
    ProfessionalProfile? profile,
    PortfolioMediaType type,
  ) {
    if (profile == null) return '';
    for (final item in profile.portfolioItems) {
      if (item.type == type) return item.url;
    }
    return '';
  }

  static List<String> _lines(String value) => value
      .split(RegExp(r'[\n,]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

class ProfessionalProfileForm extends StatefulWidget {
  const ProfessionalProfileForm({required this.controller, super.key});

  final ProfessionalProfileFormController controller;

  @override
  State<ProfessionalProfileForm> createState() =>
      _ProfessionalProfileFormState();
}

class _ProfessionalProfileFormState extends State<ProfessionalProfileForm> {
  bool _pickingPhoto = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<ProfessionalCategory>(
              initialValue: controller.category,
              isExpanded: true,
              items: [
                for (final category in professionalCategoryOptions)
                  DropdownMenuItem(
                    value: category,
                    child: Text(category.label),
                  ),
              ],
              onChanged: (value) {
                if (value != null) controller.updateCategory(value);
              },
              decoration: InputDecoration(
                labelText: context.tr('Professional activity'),
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('professional-business-name'),
              controller: controller.businessName,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.tr('Business or stage name'),
                prefixIcon: const Icon(Icons.storefront_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('professional-headline'),
              controller: controller.headline,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.tr('Professional headline'),
                hintText: context.tr('What do you bring to an event?'),
                prefixIcon: const Icon(Icons.auto_awesome_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.description,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: context.tr('Professional bio'),
                hintText: context.tr(
                  'Describe your style, expertise and ideal projects.',
                ),
                prefixIcon: const Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.tr('Services'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final service in _serviceOptions)
                  FilterChip(
                    selected: controller.services.contains(service),
                    label: Text(context.tr(service)),
                    onSelected: (_) => controller.toggleService(service),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _FormSectionTitle(
              icon: Icons.photo_library_outlined,
              title: context.tr('Portfolio'),
              subtitle: context.tr(
                'Add photos and links to videos or music samples.',
              ),
            ),
            const SizedBox(height: 10),
            _PortfolioGrid(
              items: controller.photoItems,
              loading: _pickingPhoto,
              onAdd: _pickPortfolioPhoto,
              onRemove: controller.removePhoto,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.videoLink,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.tr('Video or showreel link'),
                helperText: context.tr('YouTube, Vimeo, Drive...'),
                prefixIcon: const Icon(Icons.play_circle_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.audioLink,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.tr('Music or audio link'),
                helperText: context.tr('SoundCloud, Spotify, Mixcloud...'),
                prefixIcon: const Icon(Icons.graphic_eq_rounded),
              ),
            ),
            const SizedBox(height: 20),
            _FormSectionTitle(
              icon: Icons.history_edu_outlined,
              title: context.tr('Experience and references'),
              subtitle: context.tr(
                'List establishments, clients or events you have worked with.',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.completedProjects,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: context.tr('Events and projects completed'),
                hintText: context.tr('One reference per line'),
                prefixIcon: const Icon(Icons.event_available_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.establishments,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: context.tr('Establishments or clients'),
                hintText: context.tr('One name per line'),
                prefixIcon: const Icon(Icons.apartment_outlined),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: Text(context.tr('Years of experience'))),
                Text(
                  '${controller.yearsExperience}',
                  style: TextStyle(
                    color: AppColors.primaryBright,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            Slider(
              value: controller.yearsExperience.toDouble(),
              min: 0,
              max: 30,
              divisions: 30,
              onChanged: (value) => controller.updateExperience(value.round()),
            ),
            Row(
              children: [
                Expanded(child: Text(context.tr('Travel radius'))),
                Text(
                  '${controller.travelRadiusKm.round()} km',
                  style: TextStyle(
                    color: AppColors.primaryBright,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            Slider(
              value: controller.travelRadiusKm,
              min: 5,
              max: 200,
              divisions: 39,
              onChanged: controller.updateRadius,
            ),
            TextField(
              controller: controller.indicativeRate,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.tr('Indicative rate'),
                helperText: context.tr('Optional and non-binding'),
                prefixIcon: const Icon(Icons.payments_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.availability,
              decoration: InputDecoration(
                labelText: context.tr('Availability'),
                hintText: context.tr('Weekends, evenings, on request...'),
                prefixIcon: const Icon(Icons.calendar_month_outlined),
              ),
            ),
            const SizedBox(height: 20),
            _FormSectionTitle(
              icon: Icons.public_rounded,
              title: context.tr('Professional links'),
              subtitle: context.tr('Only add accounts used for your work.'),
            ),
            const SizedBox(height: 10),
            for (final field in [
              (controller.website, 'Website', Icons.language_rounded),
              (
                controller.instagram,
                'Instagram',
                Icons.alternate_email_rounded,
              ),
              (controller.tiktok, 'TikTok', Icons.music_video_outlined),
              (controller.soundCloud, 'SoundCloud', Icons.cloud_outlined),
              (controller.spotify, 'Spotify', Icons.album_outlined),
            ]) ...[
              TextField(
                controller: field.$1,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: context.tr(field.$2),
                  prefixIcon: Icon(field.$3),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  Future<void> _pickPortfolioPhoto() async {
    if (_pickingPhoto || widget.controller.photoItems.length >= 6) return;
    setState(() => _pickingPhoto = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 68,
        maxWidth: 1100,
        maxHeight: 1100,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.length > 1400000) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Choose a photo under 1.4 MB.')),
          );
        }
        return;
      }
      final mimeType = file.mimeType ?? 'image/jpeg';
      widget.controller.addPhoto(
        ProfessionalPortfolioItem(
          id: 'portfolio-${DateTime.now().microsecondsSinceEpoch}',
          title: file.name,
          url: 'data:$mimeType;base64,${base64Encode(bytes)}',
          type: PortfolioMediaType.image,
        ),
      );
    } finally {
      if (mounted) setState(() => _pickingPhoto = false);
    }
  }
}

class _PortfolioGrid extends StatelessWidget {
  const _PortfolioGrid({
    required this.items,
    required this.loading,
    required this.onAdd,
    required this.onRemove,
  });

  final List<ProfessionalPortfolioItem> items;
  final bool loading;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length < 6 ? items.length + 1 : items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: loading ? null : onAdd,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: loading
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.add_a_photo_outlined),
              ),
            ),
          );
        }
        final item = items[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              PullupImage(source: item.url, fit: BoxFit.cover),
              Positioned(
                top: 3,
                right: 3,
                child: IconButton.filled(
                  tooltip: context.tr('Remove photo'),
                  onPressed: () => onRemove(item.id),
                  style: IconButton.styleFrom(
                    minimumSize: const Size.square(34),
                    backgroundColor: Colors.black.withValues(alpha: 0.7),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 17),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FormSectionTitle extends StatelessWidget {
  const _FormSectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryBright),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 3),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

const _serviceOptions = <String>[
  'DJ set',
  'Photography',
  'Video production',
  'Cocktail service',
  'Bartending',
  'Security',
  'Venue rental',
  'Promotion',
  'Event planning',
  'Sound equipment',
  'Lighting',
  'Content creation',
];
