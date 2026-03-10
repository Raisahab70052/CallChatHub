import 'package:get/get.dart';

import '../data/providers/agora_provider.dart';
import '../data/providers/firebase_auth_provider.dart';
import '../viewmodels/call_controller.dart';
import '../viewmodels/timer_controller.dart';

class CallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TimerController>(TimerController.new, fenix: true);
    Get.lazyPut<CallController>(
      () => CallController(
        Get.find<AgoraProvider>(),
        Get.find<TimerController>(),
        Get.find<FirebaseAuthProvider>(),
      ),
      fenix: true,
    );
  }
}
