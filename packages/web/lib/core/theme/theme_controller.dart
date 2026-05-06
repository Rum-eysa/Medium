// ============================================================================
// THEME CONTROLLER
// ============================================================================
// Dosya: core/theme/theme_controller.dart
//
// Kullanım:
//   Get.find<ThemeController>().toggleTheme();
//   ThemeController.to.isDark
// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app_theme.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final _box = GetStorage();
  static const _key = 'isDark';

  final _isDark = true.obs; // varsayılan: dark

  bool get isDark => _isDark.value;
  ThemeData get current => isDark ? AppTheme.dark() : AppTheme.light();
  ThemeMode get mode => isDark ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    _isDark.value = _box.read<bool>(_key) ?? true;
    _applyTheme();
  }

  void toggleTheme() {
    _isDark.value = !_isDark.value;
    _box.write(_key, _isDark.value);
    _applyTheme();
  }

  void setDark(bool value) {
    _isDark.value = value;
    _box.write(_key, value);
    _applyTheme();
  }

  void _applyTheme() {
    Get.changeTheme(current);
    Get.changeThemeMode(mode);
  }
}
