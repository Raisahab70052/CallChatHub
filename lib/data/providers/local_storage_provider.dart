import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageProvider {
  LocalStorageProvider._(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalStorageProvider> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return LocalStorageProvider._(prefs);
  }

  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  String? getString(String key) => _prefs.getString(key);

  Future<bool> setString(String key, String value) => _prefs.setString(key, value);
}
