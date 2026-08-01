import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';

class SettingsProvider with ChangeNotifier {
  bool isDarkMode = false;
  bool isSoundEnabled = true;
  bool isHapticEnabled = true;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    isDarkMode = await StorageService.isDarkMode();
    isSoundEnabled = await StorageService.isSoundEnabled();
    isHapticEnabled = await StorageService.isHapticEnabled();
    notifyListeners();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    StorageService.setDarkMode(isDarkMode);
    triggerHaptic();
    notifyListeners();
  }

  void toggleSound() {
    isSoundEnabled = !isSoundEnabled;
    StorageService.setSoundEnabled(isSoundEnabled);
    triggerHaptic();
    notifyListeners();
  }

  void toggleHaptic() {
    isHapticEnabled = !isHapticEnabled;
    StorageService.setHapticEnabled(isHapticEnabled);
    triggerHaptic();
    notifyListeners();
  }

  void triggerHaptic() {
    if (isHapticEnabled) HapticFeedback.lightImpact();
  }
}
