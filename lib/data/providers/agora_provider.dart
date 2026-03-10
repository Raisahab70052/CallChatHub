import 'dart:convert';
import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/constants/app_constants.dart';

class AgoraProvider extends GetxService {
  late final RtcEngine _engine;
  bool _initialized = false;
  bool _didLogTokenServerConfig = false;
  Uri? _cachedTokenServerBaseUri;
  Uri? _cachedRtcTokenUri;

  final String _appId = const String.fromEnvironment(
    AppConstants.agoraAppIdEnv,
    defaultValue: '7c66cc0c37c94d21bab5ff32e42600f1',
  );
  final String _token = const String.fromEnvironment(
    AppConstants.agoraTokenEnv,
  );
  final String _tokenServerUrl = const String.fromEnvironment(
    AppConstants.agoraTokenServerUrlEnv,
    defaultValue: '',
  );

  Future<bool> initialize() async {
    if (_initialized) return true;
    _logTokenServerConfigIfNeeded();
    if (_appId.isEmpty) {
      Get.snackbar(
        'Agora App ID missing',
        'Provide --dart-define=${AppConstants.agoraAppIdEnv}=<id>',
      );
      return false;
    }

    final PermissionStatus micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      Get.snackbar(
        'Permission denied',
        'Microphone access is required for calls',
      );
      return false;
    }

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: _appId));
    await _engine.setChannelProfile(
      ChannelProfileType.channelProfileCommunication,
    );
    await _engine.enableAudio();
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          Get.log('Joined channel: ${connection.channelId}');
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          Get.log('Left channel: ${connection.channelId}');
        },
        onError: (ErrorCodeType err, String msg) {
          Get.log('Agora error $err: $msg');
        },
      ),
    );

    _initialized = true;
    return true;
  }

  Future<bool> joinChannel(
    String channelName, {
    required String userIdentifier,
  }) async {
    final int uid = _identifierToAgoraUid(userIdentifier);
    final String? resolvedToken = await _resolveToken(channelName, uid);
    if (resolvedToken == null || resolvedToken.isEmpty) return false;

    final bool initialized = await initialize();
    if (!initialized || !_initialized) return false;

    try {
      await _engine.joinChannel(
        token: resolvedToken,
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(),
      );
      return true;
    } catch (e) {
      Get.snackbar('Join failed', e.toString());
      return false;
    }
  }

  Future<void> leaveChannel() async {
    if (!_initialized) return;
    await _engine.leaveChannel();
  }

  Future<void> toggleMute(bool mute) async {
    if (!_initialized) return;
    await _engine.muteLocalAudioStream(mute);
  }

  Future<void> toggleSpeaker(bool speakerOn) async {
    if (!_initialized) return;
    await _engine.setEnableSpeakerphone(speakerOn);
  }

  /// Full URL to token endpoint. Example: http://10.0.2.2:4000/rtc-token
  String get tokenServerUrl => _resolveRtcTokenUri().toString();

  // / Base URL of token server. Example: http://10.0.2.2:4000
  String get tokenServerBaseUrl => _resolveTokenServerBaseUri().toString();

  Future<String?> _resolveToken(String channelName, int uid) async {
    _logTokenServerConfigIfNeeded();

    if (_token.trim().isNotEmpty) {
      return _token.trim();
    }

    try {
      final Uri uri = _resolveRtcTokenUri().replace(
        queryParameters: <String, String>{
          'channelName': channelName,
          'uid': uid.toString(),
        },
      );
      final HttpClient client = HttpClient();
      final HttpClientRequest request = await client.getUrl(uri);
      final HttpClientResponse response = await request.close();
      final String body = await response.transform(utf8.decoder).join();
      client.close(force: true);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        Get.snackbar(
          'Token server error',
          'HTTP ${response.statusCode}: $body',
        );
        return null;
      }

      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final String token = (decoded['token'] ?? '').toString();
        if (token.isNotEmpty) return token;
      }

      Get.snackbar(
        'Invalid token response',
        'Missing `token` in server response',
      );
      return null;
    } catch (e) {
      Get.snackbar(
        'Token fetch failed',
        'Start token server. Android emulator uses 10.0.2.2, physical device uses your PC LAN IP. '
            'Pass --dart-define=${AppConstants.agoraTokenServerUrlEnv}=http://<host>:4000/rtc-token',
      );
      return null;
    }
  }

  Uri _resolveTokenServerBaseUri() {
    if (_cachedTokenServerBaseUri != null) {
      return _cachedTokenServerBaseUri!;
    }

    final String configured = _tokenServerUrl.trim();
    if (configured.isNotEmpty) {
      final Uri? parsed = Uri.tryParse(configured);
      final bool valid =
          parsed != null &&
          (parsed.scheme == 'http' || parsed.scheme == 'https') &&
          parsed.host.isNotEmpty;
      if (valid) {
        final List<String> segments = List<String>.from(
          parsed!.pathSegments.where((String segment) => segment.isNotEmpty),
        );
        if (segments.isNotEmpty && segments.last == 'rtc-token') {
          segments.removeLast();
        }
        _cachedTokenServerBaseUri = parsed.replace(
          pathSegments: segments,
          query: null,
          fragment: null,
        );
        return _cachedTokenServerBaseUri!;
      }

      Get.log(
        'Invalid ${AppConstants.agoraTokenServerUrlEnv}="$configured". '
        'Falling back to production backend.',
      );
    }

    // Production backend URL
    _cachedTokenServerBaseUri = Uri.parse(
      'https://call-chat-hub.vercel.app',
    );
    return _cachedTokenServerBaseUri!;
  }

  Uri _resolveRtcTokenUri() {
    if (_cachedRtcTokenUri != null) {
      return _cachedRtcTokenUri!;
    }

    final Uri base = _resolveTokenServerBaseUri();
    final List<String> segments = <String>[
      ...base.pathSegments.where((String segment) => segment.isNotEmpty),
      'rtc-token',
    ];
    _cachedRtcTokenUri = base.replace(
      pathSegments: segments,
      query: null,
      fragment: null,
    );
    return _cachedRtcTokenUri!;
  }

  void _logTokenServerConfigIfNeeded() {
    if (_didLogTokenServerConfig) return;
    _didLogTokenServerConfig = true;

    final Uri baseUri = _resolveTokenServerBaseUri();
    final Uri tokenUri = _resolveRtcTokenUri();
    final bool staticTokenProvided = _token.trim().isNotEmpty;

    Get.log(
      '[Agora] token config -> base: $baseUri, rtc-token: $tokenUri, '
      'staticTokenProvided: $staticTokenProvided, '
      '${AppConstants.agoraTokenServerUrlEnv}: "${_tokenServerUrl.trim()}"',
    );
  }

  int _identifierToAgoraUid(String identifier) {
    int hash = 0;
    for (final int unit in identifier.codeUnits) {
      hash = ((hash * 31) + unit) & 0x7fffffff;
    }
    // Agora requires positive int uid.
    return hash == 0 ? 1 : hash;
  }

  @override
  Future<void> onClose() async {
    if (_initialized) {
      await _engine.release();
      _initialized = false;
    }
    super.onClose();
  }
}
