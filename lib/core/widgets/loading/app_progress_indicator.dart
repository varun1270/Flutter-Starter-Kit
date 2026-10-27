import 'package:flutter/material.dart';

class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({
    this.value,
    this.label,
    this.minHeight,
    this.color,
    super.key,
  });

  final double? value;
  final String? label;
  final double? minHeight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final percent = value == null ? null : '${(value! * 100).round()}%';
    return Semantics(
      label: label ?? (value == null ? 'Loading' : 'Progress'),
      value: percent,
      liveRegion: true,
      child: LinearProgressIndicator(
        value: value,
        minHeight: minHeight,
        color: color,
      ),
    );
  }
}
