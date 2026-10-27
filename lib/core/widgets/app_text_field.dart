import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField>
    with TickerProviderStateMixin {
  late final FocusNode _focusNode;
  late final AnimationController _focusController;
  late final AnimationController _typingController;
  late final Animation<double> _typingPulse;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _typingPulse =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 26),
          TweenSequenceItem(tween: ConstantTween(1.0), weight: 20),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 54),
        ]).animate(
          CurvedAnimation(
            parent: _typingController,
            curve: Curves.easeOutCubic,
          ),
        );
    widget.controller.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleTextChanged);
      widget.controller.addListener(_handleTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _focusController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (_focusNode.hasFocus) {
      _focusController.forward();
    } else {
      _focusController.reverse();
    }
  }

  void _handleTextChanged() {
    if (mounted) _typingController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AnimatedBuilder(
      animation: Listenable.merge([_focusController, _typingController]),
      builder: (context, child) {
        final focusProgress = Curves.easeOutCubic.transform(
          _focusController.value,
        );
        final typingProgress = _typingPulse.value;
        final activeProgress = (focusProgress + typingProgress * 0.18).clamp(
          0.0,
          1.0,
        );
        final borderColor = colors.outline.withValues(
          alpha: 0.22 + (focusProgress * 0.10),
        );
        final labelColor = Color.lerp(
          colors.onSurfaceVariant,
          colors.primary,
          activeProgress,
        )!;
        final fillColor = Color.lerp(
          colors.surfaceContainer,
          colors.surfaceContainerHighest,
          (focusProgress * 0.34 + typingProgress * 0.08).clamp(0.0, 1.0),
        )!;
        final borderWidth = 1.0 + (focusProgress * 0.08);

        OutlineInputBorder border(Color color, double width) =>
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: color, width: width),
            );

        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                boxShadow: focusProgress == 0 && typingProgress == 0
                    ? const []
                    : [
                        BoxShadow(
                          color: colors.primary.withValues(
                            alpha:
                                0.035 * focusProgress + 0.025 * typingProgress,
                          ),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ],
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                validator: widget.validator,
                textInputAction: widget.textInputAction,
                decoration: InputDecoration(
                  labelText: widget.label,
                  hintText: widget.hint,
                  filled: true,
                  fillColor: fillColor,
                  prefixIcon: widget.prefixIcon == null
                      ? null
                      : Icon(widget.prefixIcon, color: labelColor),
                  suffixIcon: widget.suffixIcon,
                  floatingLabelStyle: TextStyle(
                    color: labelColor,
                    fontWeight: FontWeight.w600,
                  ),
                  enabledBorder: border(borderColor, borderWidth),
                  focusedBorder: border(borderColor, borderWidth),
                  errorBorder: border(colors.error, 1),
                  focusedErrorBorder: border(colors.error, 1.2),
                ),
              ),
            ),
            IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                width: focusProgress == 0 ? 0 : 44 + (typingProgress * 22),
                height: 2,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(
                    alpha: focusProgress * 0.9 + typingProgress * 0.1,
                  ),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
