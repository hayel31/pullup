import 'package:pullup/l10n/app_material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_state.dart';
import '../../../../app/providers/theme_provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_palette.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themePreset = ref.watch(themePresetProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            key: const Key('settings-appearance'),
            leading: Icon(
              Icons.palette_outlined,
              color: AppColors.primaryBright,
            ),
            title: const Text('Colors & theme'),
            subtitle: Text(context.tr(themePreset.label)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/settings/appearance'),
          ),
          const Divider(),
          Text(
            'Privacy & safety',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.lock_outline_rounded),
            title: const Text('Private event addresses'),
            subtitle: const Text(
              'Exact locations unlock only after host approval.',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/safety'),
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Push notifications'),
            subtitle: const Text(
              'Requests, matches, messages and event updates.',
            ),
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
          ),
          ListTile(
            leading: Icon(Icons.admin_panel_settings_outlined),
            title: Text('Verification'),
            subtitle: Text(
              'Email verified. Phone and identity checks available.',
            ),
            trailing: Icon(
              Icons.verified_rounded,
              color: AppColors.primaryBright,
            ),
          ),
          const Divider(),
          Text('Account', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Sign out'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => ref.read(appControllerProvider.notifier).signOut(),
          ),
          ListTile(
            leading: const Icon(
              Icons.delete_forever_rounded,
              color: AppColors.danger,
            ),
            title: const Text(
              'Delete account',
              style: TextStyle(color: AppColors.danger),
            ),
            subtitle: const Text(
              'Permanently remove your profile and activity.',
            ),
            onTap: _confirmDeleteAccount,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete your account?'),
        content: const Text(
          'This removes your profile, requests, matches and conversations. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(appControllerProvider.notifier).deleteAccount();
    }
  }
}
