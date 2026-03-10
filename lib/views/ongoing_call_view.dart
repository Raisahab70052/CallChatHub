import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../viewmodels/call_controller.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/call_button.dart';
import '../widgets/glass_card_widget.dart';
import '../widgets/gradient_background.dart';

class OngoingCallView extends GetView<CallController> {
  const OngoingCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Obx(
          () {
            final user = controller.activeUser.value;
            return Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: controller.endCall,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
                GlassCardWidget(
                  radius: 42,
                  child: Column(
                    children: <Widget>[
                      AvatarWidget(
                        initials: user?.initials ?? 'A',
                        imageUrl: user?.avatarUrl,
                        size: AvatarWidgetSize.large,
                        heroTag: user == null ? null : 'avatar_${user.id}',
                      ),
                      const SizedBox(height: 14),
                      Text(user?.name ?? 'Unknown',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0x991A1C28)
                              : const Color(0xD9FFFFFF),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Obx(
                          () => Text(
                            controller.timerController.formatted,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Obx(
                      () => CallButton(
                        label: 'Mute',
                        icon: controller.isMuted.value
                            ? Icons.mic_off_rounded
                            : Icons.mic_rounded,
                        onTap: controller.toggleMute,
                        type: CallButtonType.icon,
                        round: true,
                        active: controller.isMuted.value,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Obx(
                      () => CallButton(
                        label: 'Speaker',
                        icon: Icons.volume_up_rounded,
                        onTap: controller.toggleSpeaker,
                        type: CallButtonType.icon,
                        round: true,
                        active: controller.isSpeakerOn.value,
                      ),
                    ),
                    const SizedBox(width: 18),
                    CallButton(
                      label: 'End',
                      icon: Icons.call_end_rounded,
                      onTap: controller.endCall,
                      type: CallButtonType.reject,
                      round: true,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
              ],
            );
          },
        ),
      ),
    );
  }
}
