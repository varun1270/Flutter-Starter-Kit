import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/loading/app_loading_button.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await ref
        .read(authControllerProvider.notifier)
        .signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
    if (!mounted) return;
    if (success) {
      context.go('/home');
    } else {
      final error = ref.read(authControllerProvider).error;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error ?? 'Unable to sign in')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return Stack(
            children: [
              SafeArea(
                child: isWide
                    ? Row(
                        children: [
                          const Expanded(flex: 5, child: _WelcomePanel()),
                          Expanded(
                            flex: 6,
                            child: _FormPanel(
                              formKey: _formKey,
                              emailController: _emailController,
                              passwordController: _passwordController,
                              obscurePassword: _obscurePassword,
                              isLoading: auth.isLoading,
                              onTogglePassword: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              onSubmit: _submit,
                            ),
                          ),
                        ],
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                        child: _FormPanel(
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          obscurePassword: _obscurePassword,
                          isLoading: auth.isLoading,
                          onTogglePassword: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          onSubmit: _submit,
                          compact: true,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onSubmit,
    this.compact = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final content = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BrandMark(),
          SizedBox(height: compact ? 36 : 72),
          Text(
            'Welcome back',
            style: theme.textTheme.displaySmall?.copyWith(
              fontSize: compact ? 32 : null,
              height: compact ? 1.12 : null,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Sign in to pick up where you left off.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: EdgeInsets.all(compact ? 20 : 28),
            decoration: BoxDecoration(
              color: colors.surfaceContainer.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.outline.withValues(alpha: 0.10)),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: emailController,
                    label: 'Email address',
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline_rounded,
                    validator: Validators.email,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: passwordController,
                    label: 'Password',
                    obscureText: obscurePassword,
                    prefixIcon: Icons.lock_outline_rounded,
                    validator: Validators.password,
                    textInputAction: TextInputAction.done,
                    suffixIcon: IconButton(
                      tooltip: obscurePassword
                          ? 'Show password'
                          : 'Hide password',
                      onPressed: onTogglePassword,
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppButton(
                      label: 'Forgot password?',
                      variant: AppButtonVariant.text,
                      onPressed: () => context.push('/forgot-password'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppLoadingButton(
                    label: 'Sign in',
                    onPressed: onSubmit,
                    isLoading: isLoading,
                    icon: Icons.arrow_forward_rounded,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('New here?', style: theme.textTheme.bodyMedium),
                AppButton(
                  label: 'Create an account',
                  variant: AppButtonVariant.text,
                  onPressed: () => context.push('/register'),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Align(
      alignment: compact ? Alignment.topCenter : Alignment.center,
      child: compact ? content : SingleChildScrollView(child: content),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: colors.surfaceContainer,
        border: Border.all(color: colors.outline.withValues(alpha: 0.14)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 92,
            right: 36,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 172,
              color: colors.primary.withValues(alpha: 0.09),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _BrandMark(inverted: true),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    'YOUR SPACE TO FOCUS',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'A calmer way\nto get things done.',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: colors.onSurface,
                    fontSize: 48,
                    height: 1.05,
                    letterSpacing: -1.8,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Keep your work, ideas, and next steps close at hand — wherever the day takes you.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.55,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Thoughtfully designed for your flow',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.inverted = false});

  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final color = inverted
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: inverted
                ? Colors.white.withValues(alpha: 0.16)
                : Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: inverted
                ? Colors.white
                : Theme.of(context).colorScheme.onPrimary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'NORTHSTAR',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
