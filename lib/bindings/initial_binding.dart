import 'package:get/get.dart';

import '../data/providers/agora_provider.dart';
import '../data/providers/firebase_auth_provider.dart';
import '../data/providers/firestore_provider.dart';
import '../viewmodels/auth_controller.dart';
import '../viewmodels/call_history_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AgoraProvider>(AgoraProvider(), permanent: true);
    Get.put<FirebaseAuthProvider>(FirebaseAuthProvider(), permanent: true);
    Get.put<FirestoreProvider>(FirestoreProvider(), permanent: true);
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true);
    }
    Get.lazyPut<CallHistoryController>(CallHistoryController.new, fenix: true);
  }
}
