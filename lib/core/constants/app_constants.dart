class AppConstants {
  const AppConstants._();

  static const String appName = 'CallChatHub';

  static const String darkStartHex = '#141624';
  static const String darkEndHex = '#07070C';
  static const String lightStartHex = '#F0F5FF';
  static const String lightEndHex = '#E6ECFC';

  static const int splashDurationMs = 1800;
  static const int listAnimationMs = 280;

  static const String prefThemeMode = 'pref_theme_mode';
  static const String prefLoggedIn = 'pref_logged_in';

  // Configure these via --dart-define for secure app builds.
  static const String agoraAppIdEnv = 'AGORA_APP_ID';
  static const String agoraTokenEnv = 'AGORA_TOKEN';
  static const String agoraTokenServerUrlEnv = 'AGORA_TOKEN_SERVER_URL';
}
