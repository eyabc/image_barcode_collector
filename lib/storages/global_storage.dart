import 'package:shared_preferences/shared_preferences.dart';

/**
 *
 */
class GlobalStorage {

  /**
   * 스토리지를 초기화 한다.
   */
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

}