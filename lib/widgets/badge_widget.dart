import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class BadgeWidget extends StatelessWidget {
  const BadgeWidget({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: dark ? AppPalette.darkAccent : AppPalette.lightAccent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
