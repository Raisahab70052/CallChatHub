import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/call_model.dart';
import '../viewmodels/call_history_controller.dart';
import '../widgets/bottom_nav_widget.dart';
import '../widgets/glass_card_widget.dart';
import '../widgets/gradient_background.dart';

class CallHistoryView extends GetView<CallHistoryController> {
  const CallHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('recent', style: Theme.of(context).textTheme.headlineMedium),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    controller.clearHistory();
                    Get.snackbar('Cleared', 'Call history removed');
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(
                () {
                  if (controller.history.isEmpty) {
                    return Center(
                      child: GlassCardWidget(
                        radius: 30,
                        child: const Text('No call history yet'),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.history.length,
                    itemBuilder: (_, int index) {
                      final CallModel call = controller.history[index];
                      final bool missed = call.status == CallStatus.missed;
                      final bool incoming = call.type == CallType.incoming;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassCardWidget(
                          radius: 30,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                incoming
                                    ? Icons.call_received_rounded
                                    : Icons.call_made_rounded,
                                color: missed
                                    ? const Color(0xFFE5596F)
                                    : const Color(0xFF25996B),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      call.userName,
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${call.status.name} · ${controller.formatDuration(call.durationInSeconds)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${call.createdAt.hour.toString().padLeft(2, '0')}:${call.createdAt.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const BottomNavWidget(currentIndex: 1),
          ],
        ),
      ),
    );
  }
}
