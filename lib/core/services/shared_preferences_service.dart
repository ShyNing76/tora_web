import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static SharedPreferences? _preferences;

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  static SharedPreferences get instance {
    if (_preferences == null) {
      throw Exception('SharedPreferences not initialized. Call SharedPreferencesService.init() first.');
    }
    return _preferences!;
  }

  /// Store a string value
  Future<bool> setString(String key, String value) async {
    return await instance.setString(key, value);
  }

  /// Get a string value
  String? getString(String key) {
    return instance.getString(key);
  }

  /// Store an integer value
  Future<bool> setInt(String key, int value) async {
    return await instance.setInt(key, value);
  }

  /// Get an integer value
  int? getInt(String key) {
    return instance.getInt(key);
  }

  /// Store a double value
  Future<bool> setDouble(String key, double value) async {
    return await instance.setDouble(key, value);
  }

  /// Get a double value
  double? getDouble(String key) {
    return instance.getDouble(key);
  }

  /// Store a boolean value
  Future<bool> setBool(String key, bool value) async {
    return await instance.setBool(key, value);
  }

  /// Get a boolean value
  bool? getBool(String key) {
    return instance.getBool(key);
  }

  /// Store a list of strings
  Future<bool> setStringList(String key, List<String> value) async {
    return await instance.setStringList(key, value);
  }

  /// Get a list of strings
  List<String>? getStringList(String key) {
    return instance.getStringList(key);
  }

  /// Remove a value
  Future<bool> remove(String key) async {
    return await instance.remove(key);
  }

  /// Clear all values
  Future<bool> clear() async {
    return await instance.clear();
  }

  /// Check if key exists
  bool containsKey(String key) {
    return instance.containsKey(key);
  }

  /// Get all keys
  Set<String> getKeys() {
    return instance.getKeys();
  }
}