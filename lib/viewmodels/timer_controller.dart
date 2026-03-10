import 'dart:async';

import 'package:get/get.dart';

class TimerController extends GetxController {
  final RxInt elapsedSeconds = 0.obs;
  Timer? _timer;

  void start() {
    stop();
    elapsedSeconds.value = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds.value++;
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  String get formatted {
    final int total = elapsedSeconds.value;
    final int h = total ~/ 3600;
    final int m = (total % 3600) ~/ 60;
    final int s = total % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    stop();
    super.onClose();
  }
}
