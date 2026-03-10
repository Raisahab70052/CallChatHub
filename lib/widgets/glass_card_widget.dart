import 'dart:ui';

import 'package:flutter/material.dart';

class GlassCardWidget extends StatelessWidget {
  const GlassCardWidget({
    super.key,
    required this.child,
    this.padding,
    this.radius = 28,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Material(
          color: dark ? const Color(0x991A1C28) : const Color(0xD9FFFFFF),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              padding: padding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: dark ? const Color(0x22FFFFFF) : const Color(0x22001428),
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
