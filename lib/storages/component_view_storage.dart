import 'dart:ffi';

import 'package:shared_preferences/shared_preferences.dart';

class ComponentViewStorage {

  // 키가 커지면 샤딩해서 가져오기로 변경
  static const String _KEY_NAME_COMPONENT_PROGRESS_BAR = "component:progress-bar";

  static Future<bool> isShowProgressBar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_KEY_NAME_COMPONENT_PROGRESS_BAR) ?? false;
  }

  static Future<void> setShowProgressBar(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_KEY_NAME_COMPONENT_PROGRESS_BAR, value);
  }

}