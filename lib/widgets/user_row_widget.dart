import 'package:flutter/material.dart';

import '../data/models/user_model.dart';
import 'avatar_widget.dart';
import 'badge_widget.dart';
import 'call_button.dart';
import 'glass_card_widget.dart';

class UserRowWidget extends StatelessWidget {
  const UserRowWidget({
    super.key,
    required this.user,
    required this.onCallTap,
    required this.onLongPress,
  });

  final UserModel user;
  final VoidCallback onCallTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onLongPress: onLongPress,
        child: GlassCardWidget(
          radius: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: <Widget>[
              AvatarWidget(
                initials: user.initials,
                imageUrl: user.avatarUrl,
                size: AvatarWidgetSize.small,
                heroTag: 'avatar_${user.id}',
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: dark ? Colors.white : const Color(0xFF1A2446),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      user.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: user.isOnline
                            ? const Color(0xFF25996B)
                            : (dark
                                ? const Color(0xFF9DA6C0)
                                : const Color(0xFF4A5675)),
                      ),
                    ),
                  ],
                ),
              ),
              if (user.unread > 0) ...<Widget>[
                BadgeWidget(value: user.unread.toString()),
                const SizedBox(width: 8),
              ],
              CallButton(
                label: 'Call',
                icon: Icons.call_rounded,
                onTap: onCallTap,
                type: CallButtonType.icon,
                round: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
