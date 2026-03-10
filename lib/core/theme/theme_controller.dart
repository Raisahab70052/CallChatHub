import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_constants.dart';
import '../../data/providers/local_storage_provider.dart';

class ThemeController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.dark.obs;
  late final LocalStorageProvider _storage;

  @override
  void onInit() {
    super.onInit();
    _storage = Get.find<LocalStorageProvider>();
    final String? savedMode = _storage.getString(AppConstants.prefThemeMode);
    if (savedMode == ThemeMode.light.name) {
      themeMode.value = ThemeMode.light;
    } else if (savedMode == ThemeMode.dark.name) {
      themeMode.value = ThemeMode.dark;
    }
  }

  bool get isDark => themeMode.value == ThemeMode.dark;

  void toggleTheme() {
    themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark;
    _storage.setString(AppConstants.prefThemeMode, themeMode.value.name);
  }
}
