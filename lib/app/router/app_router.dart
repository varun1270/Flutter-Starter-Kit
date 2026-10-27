import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/playground/presentation/loading_playground_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = auth.user != null;
      final isPublicRoute = switch (state.matchedLocation) {
        '/splash' || '/login' || '/register' || '/forgot-password' => true,
        _ => false,
      };

      if (!isAuthenticated && !isPublicRoute) return '/login';
      if (isAuthenticated &&
          const {'/login', '/register'}.contains(state.matchedLocation)) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (_, state) =>
            NoTransitionPage(key: state.pageKey, child: const SplashScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _authPage(
          context,
          state,
          const LoginScreen(),
          begin: const Offset(0, 0.035),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _authPage(
          context,
          state,
          const RegisterScreen(),
          begin: const Offset(0.06, 0),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => _authPage(
          context,
          state,
          const ForgotPasswordScreen(),
          begin: const Offset(0.06, 0),
        ),
      ),
      StatefulShellRoute(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        navigatorContainerBuilder: _animatedShellContainer,
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (_, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (_, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const ProfileScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'details',
                    pageBuilder: (context, state) => _detailPage(
                      context,
                      state,
                      const ProfileDetailsScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                pageBuilder: (_, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const SettingsScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'loading-playground',
                    pageBuilder: (context, state) => _detailPage(
                      context,
                      state,
                      const LoadingPlaygroundScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

Widget _animatedShellContainer(
  BuildContext context,
  StatefulNavigationShell navigationShell,
  List<Widget> children,
) {
  final motion = Theme.of(context).extension<MotionTheme>();
  return _AnimatedShellContainer(
    currentIndex: navigationShell.currentIndex,
    duration: motion?.standardDuration ?? AppMotion.standard,
    children: children,
  );
}

class _AnimatedShellContainer extends StatefulWidget {
  const _AnimatedShellContainer({
    required this.currentIndex,
    required this.duration,
    required this.children,
  });

  final int currentIndex;
  final Duration duration;
  final List<Widget> children;

  @override
  State<_AnimatedShellContainer> createState() =>
      _AnimatedShellContainerState();
}

class _AnimatedShellContainerState extends State<_AnimatedShellContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late int _previousIndex;
  var _direction = 1.0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant _AnimatedShellContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _direction = widget.currentIndex >= oldWidget.currentIndex ? 1 : -1;
      if (widget.duration == Duration.zero) {
        _controller.value = 1;
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = Curves.easeInOutCubic.transform(_controller.value);
          final isTransitioning =
              _controller.isAnimating && _previousIndex != widget.currentIndex;

          return Stack(
            fit: StackFit.expand,
            children: [
              for (var index = 0; index < widget.children.length; index++)
                Positioned.fill(
                  child: _AnimatedBranchLayer(
                    visible:
                        index == widget.currentIndex ||
                        (isTransitioning && index == _previousIndex),
                    active: index == widget.currentIndex,
                    incoming: index == widget.currentIndex,
                    progress: progress,
                    direction: _direction,
                    child: widget.children[index],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AnimatedBranchLayer extends StatelessWidget {
  const _AnimatedBranchLayer({
    required this.child,
    required this.visible,
    required this.active,
    required this.incoming,
    required this.progress,
    required this.direction,
  });

  final Widget child;
  final bool visible;
  final bool active;
  final bool incoming;
  final double progress;
  final double direction;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return Offstage(
        offstage: true,
        child: TickerMode(enabled: false, child: child),
      );
    }

    final opacity = incoming ? progress : 1 - progress;
    final translation = incoming
        ? direction * 0.12 * (1 - progress)
        : direction * 0.12 * progress;
    final scale = incoming ? 0.985 + (0.015 * progress) : 1 - (0.01 * progress);

    return IgnorePointer(
      ignoring: !active,
      child: TickerMode(
        enabled: active,
        child: FractionalTranslation(
          translation: Offset(translation, 0),
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.scale(scale: scale, child: child),
          ),
        ),
      ),
    );
  }
}

Page<void> _authPage(
  BuildContext context,
  GoRouterState state,
  Widget child, {
  required Offset begin,
}) {
  return _motionPage(context, state, child, begin: begin, scale: 0.985);
}

Page<void> _detailPage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return _motionPage(
    context,
    state,
    child,
    begin: const Offset(0.07, 0),
    scale: 0.98,
  );
}

Page<void> _motionPage(
  BuildContext context,
  GoRouterState state,
  Widget child, {
  required Offset begin,
  required double scale,
}) {
  final motion = Theme.of(context).extension<MotionTheme>();
  final reduceMotion =
      motion?.reduceMotion ?? false || MediaQuery.disableAnimationsOf(context);
  if (defaultTargetPlatform == TargetPlatform.iOS && !reduceMotion) {
    return CupertinoPage<void>(key: state.pageKey, child: child);
  }

  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppMotion.standard,
    reverseTransitionDuration: AppMotion.quick,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (reduceMotion) {
        return child;
      }

      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final position = Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(curve);
      final scaleAnimation = Tween<double>(begin: scale, end: 1).animate(curve);
      return FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: position,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        ),
      );
    },
  );
}
