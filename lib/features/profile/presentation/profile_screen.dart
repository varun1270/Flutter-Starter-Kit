import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_card.dart';
import '../../auth/presentation/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final displayName = user?.displayName ?? 'Alex Morgan';
    final email = user?.email ?? 'alex@example.com';
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => context.push('/profile/details'),
                  child: Hero(
                    tag: 'profile-avatar',
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.14),
                      child: Text(
                        displayName.substring(0, 1),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(email, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 28),
          AppCard(
            child: Column(
              children: const [
                _ProfileRow(
                  icon: Icons.work_outline_rounded,
                  label: 'Workspace',
                  value: 'Northstar Studio',
                ),
                Divider(height: 28),
                _ProfileRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Member since',
                  value: 'October 2026',
                ),
                Divider(height: 28),
                _ProfileRow(
                  icon: Icons.verified_outlined,
                  label: 'Plan',
                  value: 'Starter kit',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit profile'),
          ),
        ],
      ),
    );
  }
}

class ProfileDetailsScreen extends ConsumerWidget {
  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final displayName = user?.displayName ?? 'Alex Morgan';
    final email = user?.email ?? 'alex@example.com';
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile details')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Hero(
                tag: 'profile-avatar',
                child: CircleAvatar(
                  radius: 72,
                  backgroundColor: colors.primary.withValues(alpha: 0.14),
                  child: Text(
                    displayName.substring(0, 1),
                    style: Theme.of(
                      context,
                    ).textTheme.displaySmall?.copyWith(color: colors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                displayName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(email, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 28),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: colors.primary),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Your profile is ready to grow with the next feature you build.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 14),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
