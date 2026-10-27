import 'package:flutter/material.dart';

import '../app_button.dart';

class AppLoadingButton extends StatelessWidget {
  const AppLoadingButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isLoading ? '$label, loading' : label,
      button: true,
      child: AppButton(
        label: label,
        onPressed: onPressed,
        isLoading: isLoading,
        variant: variant,
        icon: icon,
      ),
    );
  }
}
