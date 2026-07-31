import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/game_theme.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isSoundOn = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    bool sound = await StorageService.isSoundEnabled();
    setState(() => isSoundOn = sound);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: GameTheme.textDark),
        title: Text('Settings', style: GoogleFonts.poppins(color: GameTheme.textDark, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            color: GameTheme.blockSurface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
          ),
          child: SwitchListTile(
            title: Text('Sound Effects', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: GameTheme.textDark)),
            value: isSoundOn,
            activeColor: GameTheme.upColor,
            onChanged: (val) {
              setState(() => isSoundOn = val);
              StorageService.setSoundEnabled(val);
            },
          ),
        ),
      ),
    );
  }
}
