import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_card.dart';
import '../../auth/presentation/auth_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _refresh() async {
    // Replace this with the home repository refresh when backend data is wired.
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final colors = Theme.of(context).colorScheme;
    final name = user?.displayName?.split(' ').first ?? 'there';
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth > 700 ? 48.0 : 20.0;
          return RefreshIndicator.adaptive(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                18,
                horizontalPadding,
                32,
              ),
              children: [
                _DashboardHeader(
                  name: name,
                  onNotifications: () =>
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('You’re all caught up.')),
                      ),
                ),
                const SizedBox(height: 24),
                const _FocusHeroCard(),
                const SizedBox(height: 24),
                const _OverviewCard(),
                const SizedBox(height: 24),
                _NextUpCard(colors: colors),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.name, required this.onNotifications});

  final String name;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR NORTHSTAR',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Good morning, $name',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'A clear view of what is moving forward.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Notifications',
          onPressed: onNotifications,
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}

class _FocusHeroCard extends StatelessWidget {
  const _FocusHeroCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 18, 20),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outline.withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'MOMENTUM',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'You’re in a good rhythm.',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'One focused step is enough to move the whole project forward.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: 0.82,
                    minHeight: 7,
                    backgroundColor: colors.primary.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(colors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '82% of this week’s intention complete',
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                  label: const Text('View your plan'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _ProgressOrb(value: 0.82),
        ],
      ),
    );
  }
}

class _ProgressOrb extends StatelessWidget {
  const _ProgressOrb({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: 82,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 7,
            strokeCap: StrokeCap.round,
            backgroundColor: colors.primary.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(colors.primary),
          ),
          Text(
            '${(value * 100).round()}%',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final metrics = [
      ('Focus time', '12h 40m', '+18%', Icons.bolt_rounded),
      ('Completed', '24', '+6 this week', Icons.check_circle_outline_rounded),
      ('Momentum', '82%', 'On track', Icons.insights_rounded),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your overview', style: theme.textTheme.titleLarge),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.outline.withValues(alpha: 0.14)),
          ),
          child: Row(
            children: [
              for (var index = 0; index < metrics.length; index++) ...[
                if (index > 0)
                  SizedBox(
                    height: 58,
                    child: VerticalDivider(
                      width: 1,
                      color: colors.outline.withValues(alpha: 0.16),
                    ),
                  ),
                Expanded(
                  child: _OverviewMetric(
                    label: metrics[index].$1,
                    value: metrics[index].$2,
                    change: metrics[index].$3,
                    icon: metrics[index].$4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({
    required this.label,
    required this.value,
    required this.change,
    required this.icon,
  });

  final String label;
  final String value;
  final String change;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Icon(icon, color: colors.primary, size: 19),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: 4),
          Text(
            change,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(color: colors.primary),
          ),
        ],
      ),
    );
  }
}

class _NextUpCard extends StatelessWidget {
  const _NextUpCard({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Next up', style: theme.textTheme.titleLarge),
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            children: [
              _NextItem(
                icon: Icons.edit_note_rounded,
                title: 'Shape your product brief',
                subtitle: 'Today · 30 minutes',
                color: colors.primary,
              ),
              const Divider(height: 28),
              _NextItem(
                icon: Icons.forum_outlined,
                title: 'Share a progress update',
                subtitle: 'Tomorrow · 15 minutes',
                color: colors.secondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NextItem extends StatelessWidget {
  const _NextItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded),
      ],
    );
  }
}
