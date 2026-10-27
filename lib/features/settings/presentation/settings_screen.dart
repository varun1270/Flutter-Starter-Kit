import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/theme/theme_controller.dart';
import '../../../app/theme/theme_settings.dart';
import '../../../core/widgets/app_card.dart';
import '../../auth/presentation/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(themeControllerProvider).value ?? const ThemeSettings();
    final controller = ref.read(themeControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: settings.reduceMotion ? Duration.zero : AppMotion.quick,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _ThemeSummary(
              key: ValueKey(
                '${settings.designTheme.name}-${settings.colorScheme.name}-${settings.appearance.name}',
              ),
              settings: settings,
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Design theme',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Text(
                  settings.designTheme.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppDesignTheme.values
                      .map(
                        (theme) => ChoiceChip(
                          label: Text(theme.label),
                          selected: settings.designTheme == theme,
                          onSelected: (_) => controller.setDesignTheme(theme),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Color scheme',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Text(
                  'Change the brand accent independently from the design style.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppColorScheme.values
                      .map(
                        (palette) => ChoiceChip(
                          avatar: CircleAvatar(
                            radius: 8,
                            backgroundColor: AppTheme.paletteColor(palette),
                          ),
                          label: Text(palette.label),
                          selected: settings.colorScheme == palette,
                          onSelected: (_) => controller.setColorScheme(palette),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance mode',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Text(
                  'Choose whether the app follows the device or stays in one mode.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedButton<AppAppearanceMode>(
                    showSelectedIcon: false,
                    segments: AppAppearanceMode.values
                        .map(
                          (mode) => ButtonSegment<AppAppearanceMode>(
                            value: mode,
                            label: Text(mode.label),
                            icon: Icon(mode.icon),
                          ),
                        )
                        .toList(),
                    selected: {settings.appearance},
                    onSelectionChanged: (selection) =>
                        controller.setAppearance(selection.first),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Developer tools',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.science_outlined),
              title: const Text('Loading playground'),
              subtitle: const Text(
                'Preview loaders, skeletons, overlays, and async states',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/settings/loading-playground'),
            ),
          ),
          const SizedBox(height: 28),
          Text('Accessibility', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: SwitchListTile.adaptive(
              value: settings.reduceMotion,
              onChanged: controller.setReduceMotion,
              title: const Text('Reduce motion'),
              subtitle: const Text(
                'Use simpler transitions and honor motion sensitivity.',
              ),
              secondary: const Icon(Icons.motion_photos_off_outlined),
            ),
          ),
          const SizedBox(height: 28),
          Text('Account', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.shield_outlined),
                  title: const Text('Privacy and security'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded),
                  title: const Text('Help center'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.logout_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'Sign out',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onTap: () async {
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Northstar Starter Kit · v1.0.0',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeSummary extends StatelessWidget {
  const _ThemeSummary({required this.settings, super.key});

  final ThemeSettings settings;

  @override
  Widget build(BuildContext context) {
    final paletteColor = AppTheme.paletteColor(settings.colorScheme);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: paletteColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: paletteColor.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: paletteColor,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: const Icon(Icons.palette_outlined, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${settings.designTheme.label} · ${settings.colorScheme.label}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  '${settings.appearance.label} appearance',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Icon(Icons.auto_awesome_rounded, color: paletteColor),
        ],
      ),
    );
  }
}
