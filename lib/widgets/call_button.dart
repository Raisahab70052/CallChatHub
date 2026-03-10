import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

enum CallButtonType { primary, accept, reject, icon }

class CallButton extends StatefulWidget {
  const CallButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.type = CallButtonType.primary,
    this.round = false,
    this.active = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final CallButtonType type;
  final bool round;
  final bool active;

  @override
  State<CallButton> createState() => _CallButtonState();
}

class _CallButtonState extends State<CallButton> {
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    Color background;
    switch (widget.type) {
      case CallButtonType.accept:
        background = AppPalette.success;
      case CallButtonType.reject:
        background = AppPalette.danger;
      case CallButtonType.icon:
        background = widget.active
            ? (dark ? AppPalette.darkAccent : AppPalette.lightAccent)
            : (dark ? const Color(0xCC1A1C28) : const Color(0xE6FFFFFF));
      case CallButtonType.primary:
        background = dark ? const Color(0xCC1A1C28) : const Color(0xE6FFFFFF);
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => scale = 0.96),
      onTapCancel: () => setState(() => scale = 1),
      onTapUp: (_) => setState(() => scale = 1),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        scale: scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.round ? 60 : null,
          height: widget.round ? 60 : null,
          padding: widget.round
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.round ? 30 : 40),
            gradient: widget.type == CallButtonType.primary
                ? LinearGradient(
                    colors: dark
                        ? const <Color>[Color(0xFF5F7CFF), Color(0xFF8A70F0)]
                        : const <Color>[Color(0xFF2B4FE0), Color(0xFF6A4FE0)],
                  )
                : null,
            color: widget.type == CallButtonType.primary ? null : background,
            border: Border.all(
              color: dark ? const Color(0x22FFFFFF) : const Color(0x22001428),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: (widget.type == CallButtonType.primary
                        ? (dark ? AppPalette.darkAccent : AppPalette.lightAccent)
                        : Colors.black)
                    .withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                widget.icon,
                size: 20,
                color: widget.type == CallButtonType.primary ||
                        widget.type == CallButtonType.accept ||
                        widget.type == CallButtonType.reject ||
                        widget.active
                    ? Colors.white
                    : (dark ? Colors.white : const Color(0xFF1A2446)),
              ),
              if (!widget.round) ...<Widget>[
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: widget.type == CallButtonType.primary ||
                            widget.type == CallButtonType.accept ||
                            widget.type == CallButtonType.reject
                        ? Colors.white
                        : (dark ? Colors.white : const Color(0xFF1A2446)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
