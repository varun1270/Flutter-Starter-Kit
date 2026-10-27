import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, text }

class AppButton extends StatelessWidget {
  const AppButton({
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
    final child = isLoading
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    return SizedBox(
      height: variant == AppButtonVariant.text ? 42 : 54,
      width: variant == AppButtonVariant.text ? null : double.infinity,
      child: switch (variant) {
        AppButtonVariant.primary => FilledButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
        AppButtonVariant.secondary => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
        AppButtonVariant.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      },
    );
  }
}
