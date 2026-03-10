import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../viewmodels/call_controller.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/call_button.dart';
import '../widgets/glass_card_widget.dart';
import '../widgets/gradient_background.dart';

class IncomingCallView extends GetView<CallController> {
  const IncomingCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Obx(
          () {
            final user = controller.activeUser.value;
            return Column(
              children: <Widget>[
                const SizedBox(height: 16),
                Text('incoming call', style: Theme.of(context).textTheme.labelLarge),
                const Spacer(),
                GlassCardWidget(
                  radius: 40,
                  child: Column(
                    children: <Widget>[
                      AvatarWidget(
                        initials: user?.initials ?? 'A',
                        imageUrl: user?.avatarUrl,
                        size: AvatarWidgetSize.large,
                        heroTag: user == null ? null : 'avatar_${user.id}',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name ?? 'Unknown caller',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text('CallChatHub · voice', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CallButton(
                      label: 'Reject',
                      icon: Icons.call_end_rounded,
                      type: CallButtonType.reject,
                      onTap: controller.rejectCall,
                      round: true,
                    ),
                    const SizedBox(width: 26),
                    CallButton(
                      label: 'Accept',
                      icon: Icons.call_rounded,
                      type: CallButtonType.accept,
                      onTap: controller.acceptCall,
                      round: true,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text('tap answer or reject', style: Theme.of(context).textTheme.labelLarge),
              ],
            );
          },
        ),
      ),
    );
  }
}
