import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core/routes/app_routes.dart';
import '../data/models/call_model.dart';
import '../data/models/user_model.dart';
import '../data/providers/agora_provider.dart';
import '../data/providers/firebase_auth_provider.dart';
import 'timer_controller.dart';

class CallController extends GetxController {
  CallController(this._agoraProvider, this._timerController, this._authProvider);

  final AgoraProvider _agoraProvider;
  final TimerController _timerController;
  final FirebaseAuthProvider _authProvider;

  final RxBool isMuted = false.obs;
  final RxBool isSpeakerOn = true.obs;
  final Rxn<UserModel> activeUser = Rxn<UserModel>();
  final RxString activeChannelId = ''.obs;

  TimerController get timerController => _timerController;

  @override
  void onInit() {
    super.onInit();
    bool autoJoin = false;
    final dynamic args = Get.arguments;
    if (args is Map<String, dynamic>) {
      final dynamic userArg = args['user'];
      final dynamic channelArg = args['channelId'];
      final dynamic isCallerArg = args['isCaller'];
      if (userArg is UserModel) {
        activeUser.value = userArg;
      }
      if (channelArg is String && channelArg.isNotEmpty) {
        activeChannelId.value = channelArg;
      }
      if (isCallerArg == true) autoJoin = true;
    } else if (args is UserModel) {
      activeUser.value = args;
      activeChannelId.value = 'legacy_${DateTime.now().microsecondsSinceEpoch}';
    }

    if (autoJoin) {
      // Caller auto-joins the Agora channel after the first frame.
      Future<void>.delayed(Duration.zero, acceptCall);
    }
  }

  Future<void> acceptCall() async {
    if (activeUser.value == null) return;
    final String? emailId = _authProvider.currentEmail;
    if (emailId == null || emailId.isEmpty) {
      Get.snackbar('Not signed in', 'Please log in with your Gmail to start calls.');
      return;
    }

    await HapticFeedback.mediumImpact();
    final String channelName = activeChannelId.value.isEmpty
        ? 'fallback_${DateTime.now().microsecondsSinceEpoch}'
        : activeChannelId.value;

    final bool joined = await _agoraProvider.joinChannel(
      channelName,
      userIdentifier: emailId,
    );
    if (!joined) return;

    _timerController.start();
    Get.offNamed(
      AppRoutes.ongoingCall,
      arguments: <String, dynamic>{
        'user': activeUser.value,
        'channelId': channelName,
      },
    );
    Get.snackbar('Call connected', 'You are now live with ${activeUser.value!.name}');
  }

  Future<void> rejectCall() async {
    await HapticFeedback.heavyImpact();
    await _agoraProvider.leaveChannel();
    _timerController.stop();
    Get.back<void>();
    Get.snackbar('Call rejected', 'Incoming call was declined');
  }

  Future<void> endCall() async {
    await _agoraProvider.leaveChannel();
    _timerController.stop();
    Get.dialog<void>(
      AlertDialog(
        title: const Text('Call ended'),
        content: Text('Duration: ${_timerController.formatted}'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back<void>();
              Get.offAllNamed(AppRoutes.home);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> toggleMute() async {
    isMuted.value = !isMuted.value;
    await _agoraProvider.toggleMute(isMuted.value);
    await HapticFeedback.selectionClick();
  }

  Future<void> toggleSpeaker() async {
    isSpeakerOn.value = !isSpeakerOn.value;
    await _agoraProvider.toggleSpeaker(isSpeakerOn.value);
    await HapticFeedback.selectionClick();
  }

  CallModel toHistoryEntry() {
    return CallModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: activeUser.value?.name ?? 'Unknown',
      type: CallType.outgoing,
      status: CallStatus.completed,
      createdAt: DateTime.now(),
      durationInSeconds: _timerController.elapsedSeconds.value,
    );
  }
}
