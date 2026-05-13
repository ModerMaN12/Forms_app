import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../../core/localization/locale_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appLocalizationsProvider);
    final authState = ref.watch(authProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            CircleAvatar(
              radius: 48,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                authState.user?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Text(authState.user?.name ?? 'User', style: Theme.of(context).textTheme.headlineSmall),
            if (authState.user != null) ...[
              const SizedBox(height: 4),
              Text(authState.user!.email, style: TextStyle(color: Colors.grey[600])),
            ],
            const SizedBox(height: 32),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.language),
              trailing: SegmentedButton<Locale>(
                segments: [
                  ButtonSegment(value: const Locale('en'), label: Text(l10n.english)),
                  ButtonSegment(value: const Locale('ru'), label: Text(l10n.russian)),
                ],
                selected: {currentLocale},
                onSelectionChanged: (set) {
                  ref.read(localeProvider.notifier).setLocale(set.first);
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l10n.logout),
              onTap: () {
                ref.read(authProvider.notifier).logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
