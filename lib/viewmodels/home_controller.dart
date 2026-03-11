import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';

import '../core/routes/app_routes.dart';
import '../data/models/user_model.dart';
import '../data/providers/agora_provider.dart';
import '../data/providers/firebase_auth_provider.dart';
import '../data/providers/firestore_provider.dart';

class HomeController extends GetxController {
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<UserModel> filteredUsers = <UserModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;

  Worker? _debounceWorker;
  StreamSubscription<List<UserModel>>? _usersSubscription;
  late final FirebaseAuthProvider _authProvider;
  late final FirestoreProvider _firestoreProvider;
  late final AgoraProvider _agoraProvider;

  @override
  void onInit() {
    super.onInit();
    _authProvider = Get.find<FirebaseAuthProvider>();
    _firestoreProvider = Get.find<FirestoreProvider>();
    _agoraProvider = Get.find<AgoraProvider>();
    _subscribeToUsers();
    _debounceWorker = debounce<String>(
      searchQuery,
      (_) => _applyFilter(),
      time: const Duration(milliseconds: 350),
    );
  }

  void _subscribeToUsers() {
    final String currentUid = _authProvider.currentUser?.uid ?? '';
    isLoading.value = true;
    _usersSubscription = _firestoreProvider
        .streamOtherUsers(currentUid)
        .listen(
          (List<UserModel> list) {
            users.assignAll(list);
            _applyFilter();
            isLoading.value = false;
          },
          onError: (Object e) {
            debugPrint('[Home] Firestore stream error: $e');
            isLoading.value = false;
          },
        );
  }

  Future<void> refreshUsers() async {
    isRefreshing.value = true;
    await HapticFeedback.lightImpact();
    // The stream is live — just re-trigger the filter animation.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _applyFilter();
    isRefreshing.value = false;
  }

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  void openHistory() {
    Get.toNamed(AppRoutes.callHistory);
  }

  Future<void> makeCall(UserModel user) async {
    if (user.fcmToken == null || user.fcmToken!.isEmpty) {
      Get.snackbar(
        'Cannot call',
        '${user.name} is not available right now.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await _triggerHaptic();

    final String callerEmail = _authProvider.currentEmail ?? '';
    final String callerUid = _authProvider.currentUser?.uid ?? '';
    final String callerName = callerEmail.isNotEmpty
        ? callerEmail.split('@').first
        : 'Unknown';
    final String channelId = _buildPrivateChannelId(callerUid, user.id);

    // Send push notification to callee via token server.
    try {
      final String baseUrl = _agoraProvider.tokenServerBaseUrl;
      final http.Response response = await http
          .post(
            Uri.parse('$baseUrl/send-call-notification'),
            headers: <String, String>{'Content-Type': 'application/json'},
            body: jsonEncode(<String, String>{
              'toFcmToken': user.fcmToken!,
              'callerName': callerName,
              'callerEmail': callerEmail,
              'callerId': callerUid,
              'channelId': channelId,
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        debugPrint('[Home] FCM notify failed: ${response.body}');
        Get.snackbar('Call failed', 'Could not reach ${user.name}.');
        return;
      }
    } catch (e) {
      debugPrint('[Home] send-call-notification error: $e');
      Get.snackbar('Call failed', 'Token server unreachable. Is it running?');
      return;
    }

    // Caller joins the Agora channel immediately and waits for callee.
    Get.toNamed(
      AppRoutes.ongoingCall,
      arguments: <String, dynamic>{
        'user': user,
        'channelId': channelId,
        'isCaller': true,
      },
    );
  }

  Future<void> showQuickActions(UserModel user) async {
    await _triggerHaptic();
    Get.bottomSheet<void>(
      SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Get.isDarkMode
                ? const Color(0xE61A1C28)
                : const Color(0xF5FFFFFF),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('Start voice call'),
                leading: const Icon(Icons.call_rounded),
                onTap: () {
                  Get.back<void>();
                  makeCall(user);
                },
              ),
              ListTile(
                title: const Text('View call history'),
                leading: const Icon(Icons.history_rounded),
                onTap: () {
                  Get.back<void>();
                  openHistory();
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _applyFilter() {
    final String q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) {
      filteredUsers.assignAll(users);
      return;
    }

    filteredUsers.assignAll(
      users.where(
        (UserModel user) =>
            user.name.toLowerCase().contains(q) ||
            user.email.toLowerCase().contains(q),
      ),
    );
  }

  Future<void> _triggerHaptic() async {
    final bool hasVibrator = (await Vibration.hasVibrator()) == true;
    if (hasVibrator) {
      await Vibration.vibrate(duration: 30);
    } else {
      await HapticFeedback.selectionClick();
    }
  }

  String _buildPrivateChannelId(String callerId, String calleeId) {
    final int ts = DateTime.now().microsecondsSinceEpoch;
    final int nonce = Random.secure().nextInt(1 << 20);
    final String callerHash = _shortHash(callerId);
    final String calleeHash = _shortHash(calleeId);
    return 'chh_${callerHash}_${calleeHash}_${ts}_$nonce';
  }

  String _shortHash(String input) {
    int hash = 0;
    for (final int unit in input.codeUnits) {
      hash = ((hash * 31) + unit) & 0x7fffffff;
    }
    return hash.toRadixString(36);
  }

  @override
  void onClose() {
    _debounceWorker?.dispose();
    _usersSubscription?.cancel();
    super.onClose();
  }
}
