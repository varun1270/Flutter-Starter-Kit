import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/loading/app_loading_button.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await ref
        .read(authControllerProvider.notifier)
        .register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
    if (!mounted) return;
    if (success) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(authControllerProvider).error ??
                'Unable to create account',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create your account',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'A calm workspace for your next big idea.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 30),
                  AppCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _nameController,
                            label: 'Full name',
                            prefixIcon: Icons.person_outline_rounded,
                            validator: (value) =>
                                Validators.required(value, label: 'Name'),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _emailController,
                            label: 'Email address',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.alternate_email_rounded,
                            validator: Validators.email,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _passwordController,
                            label: 'Create a password',
                            obscureText: true,
                            prefixIcon: Icons.lock_outline_rounded,
                            validator: Validators.password,
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: 24),
                          AppLoadingButton(
                            label: 'Create account',
                            onPressed: _submit,
                            isLoading: auth.isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: AppButton(
                      label: 'Already have an account? Sign in',
                      variant: AppButtonVariant.text,
                      onPressed: () => context.go('/login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
