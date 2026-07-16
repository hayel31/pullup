import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_state.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: Icon(Icons.lock_outline_rounded),
            title: Text('Privacy'),
            subtitle: Text(
              'Exact addresses are only available after host approval.',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('Push notifications'),
            subtitle: Text('Firebase Cloud Messaging adapter is prepared.'),
          ),
          const ListTile(
            leading: Icon(Icons.admin_panel_settings_outlined),
            title: Text('Verification'),
            subtitle: Text(
              'Email, phone, selfie, identity, host and DJ badges are modeled.',
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Sign out'),
            onTap: () => ref.read(appControllerProvider.notifier).signOut(),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_rounded),
            title: const Text('Delete account'),
            onTap: () =>
                ref.read(appControllerProvider.notifier).deleteAccount(),
          ),
        ],
      ),
    );
  }
}
