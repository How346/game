import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<int> getUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('unlocked_level') ?? 1;
  }

  static Future<void> saveUnlockedLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    int currentUnlocked = await getUnlockedLevel();
    if (level > currentUnlocked) await prefs.setInt('unlocked_level', level);
  }

  static Future<bool> isSoundEnabled() async => (await SharedPreferences.getInstance()).getBool('sound') ?? true;
  static Future<void> setSoundEnabled(bool v) async => (await SharedPreferences.getInstance()).setBool('sound', v);

  static Future<bool> isHapticEnabled() async => (await SharedPreferences.getInstance()).getBool('haptic') ?? true;
  static Future<void> setHapticEnabled(bool v) async => (await SharedPreferences.getInstance()).setBool('haptic', v);

  static Future<bool> isDarkMode() async => (await SharedPreferences.getInstance()).getBool('dark_mode') ?? false;
  static Future<void> setDarkMode(bool v) async => (await SharedPreferences.getInstance()).setBool('dark_mode', v);

  static Future<int> getBestSteps(int level) async => (await SharedPreferences.getInstance()).getInt('best_steps_$level') ?? 999;
  static Future<bool> saveBestSteps(int level, int steps) async {
    final prefs = await SharedPreferences.getInstance();
    int currentBest = await getBestSteps(level);
    if (steps < currentBest) {
      await prefs.setInt('best_steps_$level', steps);
      return true;
    }
    return false;
  }

  // --- NEW: Stars Storage ---
  static Future<int> getStars(int level) async => (await SharedPreferences.getInstance()).getInt('stars_$level') ?? 0;
  
  static Future<void> saveStars(int level, int stars) async {
    final prefs = await SharedPreferences.getInstance();
    int currentStars = await getStars(level);
    // Only overwrite if the player earned more stars than before
    if (stars > currentStars) {
      await prefs.setInt('stars_$level', stars);
    }
  }
}
