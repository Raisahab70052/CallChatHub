import 'package:get/get.dart';

import '../data/models/call_model.dart';

class CallHistoryController extends GetxController {
  final RxList<CallModel> history = <CallModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  void loadHistory() {
    history.assignAll(<CallModel>[
      CallModel(
        id: 'h1',
        userName: 'Emma Watson',
        type: CallType.outgoing,
        status: CallStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
        durationInSeconds: 764,
      ),
      CallModel(
        id: 'h2',
        userName: 'James Brown',
        type: CallType.incoming,
        status: CallStatus.missed,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        durationInSeconds: 0,
      ),
      CallModel(
        id: 'h3',
        userName: 'Mia Garcia',
        type: CallType.incoming,
        status: CallStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        durationInSeconds: 722,
      ),
    ]);
  }

  void clearHistory() {
    history.clear();
  }

  String formatDuration(int seconds) {
    if (seconds <= 0) return '0s';
    final int mins = seconds ~/ 60;
    final int secs = seconds % 60;
    if (mins <= 0) return '${secs}s';
    return '${mins}m ${secs.toString().padLeft(2, '0')}s';
  }
}
