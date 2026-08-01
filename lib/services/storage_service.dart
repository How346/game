import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyUnlockedLevel = 'unlocked_level';
  static const String _keySound = 'sound_enabled';

  static Future<int> getUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    // Defaults to level 1 if no data is saved yet
    return prefs.getInt(_keyUnlockedLevel) ?? 1;
  }

  static Future<void> saveUnlockedLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    int currentUnlocked = await getUnlockedLevel();
    
    // Only save if the new level is higher than the currently unlocked level
    if (level > currentUnlocked) {
      await prefs.setInt(_keyUnlockedLevel, level);
    }
  }

  static Future<bool> isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySound) ?? true;
  }

  static Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySound, enabled);
  }
}
