import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../models/enums.dart';
import '../../../shared/domain/app_drafts.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController _displayName;
  late final TextEditingController _bio;
  late final TextEditingController _city;
  late final TextEditingController _occupation;
  late final TextEditingController _instagram;
  late final Set<String> _genres;
  late final Set<String> _interests;

  @override
  void initState() {
    super.initState();
    final user = ref.read(appControllerProvider).currentUser!;
    _displayName = TextEditingController(text: user.displayName);
    _bio = TextEditingController(text: user.bio);
    _city = TextEditingController(text: user.city);
    _occupation = TextEditingController(text: user.occupation);
    _instagram = TextEditingController(text: user.instagramHandle);
    _genres = user.musicPreferences.toSet();
    _interests = user.interests.toSet();
  }

  @override
  void dispose() {
    _displayName.dispose();
    _bio.dispose();
    _city.dispose();
    _occupation.dispose();
    _instagram.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(appControllerProvider).currentUser!;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(
            'Profile details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Keep this clear and current so hosts can review requests quickly.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _displayName,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Name shown on PULLUP',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bio,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Bio',
              hintText: 'What should a host know about you?',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _city,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'City',
              prefixIcon: Icon(Icons.location_city_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _occupation,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Work or studies',
              helperText: 'Optional',
              prefixIcon: Icon(Icons.work_outline_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _instagram,
            decoration: const InputDecoration(
              labelText: 'Instagram',
              helperText: 'Optional',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 16),
          _Picker(
            title: 'Music preferences',
            selected: _genres,
            values: musicGenreOptions.take(10).toList(),
          ),
          const SizedBox(height: 16),
          _Picker(
            title: 'Night interests',
            selected: _interests,
            values: const [
              'Rooftops',
              'Pool parties',
              'Afters',
              'Boat parties',
              'Festivals',
              'Cocktails',
            ],
          ),
          const SizedBox(height: 20),
          GradientButton(
            label: 'Save profile',
            icon: Icons.check_rounded,
            onPressed: () async {
              await ref
                  .read(appControllerProvider.notifier)
                  .updateProfile(
                    ProfileUpdateDraft(
                      displayName: _displayName.text.trim(),
                      bio: _bio.text.trim(),
                      city: _city.text.trim(),
                      interests: _interests.toList(),
                      musicPreferences: _genres.toList(),
                      languages: user.languages,
                      profilePhotos: user.profilePhotos,
                      occupation: _occupation.text.trim(),
                      instagramHandle: _instagram.text.trim(),
                    ),
                  );
              if (context.mounted) context.pop();
            },
          ),
        ],
      ),
    );
  }
}

class _Picker extends StatefulWidget {
  const _Picker({
    required this.title,
    required this.selected,
    required this.values,
  });

  final String title;
  final Set<String> selected;
  final List<String> values;

  @override
  State<_Picker> createState() => _PickerState();
}

class _PickerState extends State<_Picker> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in widget.values)
              FilterChip(
                selected: widget.selected.contains(value),
                label: Text(value),
                onSelected: (_) => setState(() {
                  widget.selected.contains(value)
                      ? widget.selected.remove(value)
                      : widget.selected.add(value);
                }),
              ),
          ],
        ),
      ],
    );
  }
}
