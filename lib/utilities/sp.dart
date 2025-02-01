import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? _sharedPreferences;

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> saveData(String key, dynamic value) async {
    if (value is bool) {
      return await _sharedPreferences!.setBool(key, value);
    } else if (value is String) {
      return await _sharedPreferences!.setString(key, value);
    } else if (value is int) {
      return await _sharedPreferences!.setInt(key, value);
    } else if (value is double) {
      return await _sharedPreferences!.setDouble(key, value);
    }
    return false;
  }

  static dynamic getData(String key) {
    return _sharedPreferences?.get(key);
  }

  static Future<bool> removeData(String key) async {
    return await _sharedPreferences!.remove(key);
  }
}
