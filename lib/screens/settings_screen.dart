import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/storage_service.dart';
import '../widgets/clay_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Progress', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete all your unlocked levels, best scores, and stars? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await StorageService.clearAllProgress();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Game progress has been reset!'),
                  backgroundColor: Colors.green,
                ));
              }
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? const Color(0xFF1E2235) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text('Settings', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildToggleTile('Theme', 'Dark Mode', Icons.dark_mode, cardColor, textColor, settings.isDarkMode, settings.toggleTheme),
          const SizedBox(height: 15),
          _buildToggleTile('Sound Effects', 'Enabled', Icons.volume_up, cardColor, textColor, settings.isSoundEnabled, settings.toggleSound),
          const SizedBox(height: 15),
          _buildToggleTile('Haptic Vibration', 'Enabled', Icons.vibration, cardColor, textColor, settings.isHapticEnabled, settings.toggleHaptic),
          const SizedBox(height: 15),
          _buildLinkTile('Reset Game Progress', 'Clear all stars and levels', Icons.delete_outline, cardColor, Colors.redAccent, () => _showResetDialog(context)),
        ],
      ),
    );
  }

  Widget _buildToggleTile(String title, String sub, IconData icon, Color bg, Color text, bool value, VoidCallback onTap) {
    return ClayCard(
      color: bg, shadowColor: Colors.black12, padding: const EdgeInsets.all(12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: text)),
        subtitle: Text(sub, style: TextStyle(color: text.withValues(alpha: 0.5))),
        trailing: Switch(value: value, onChanged: (v) => onTap(), activeTrackColor: Colors.blueAccent, activeThumbColor: Colors.white),
      ),
    );
  }

  Widget _buildLinkTile(String title, String sub, IconData icon, Color bg, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClayCard(
        color: bg, shadowColor: Colors.black12, padding: const EdgeInsets.all(12),
        child: ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(sub),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        ),
      ),
    );
  }
}
