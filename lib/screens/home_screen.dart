import 'package:flutter/material.dart';
import 'settings_screen.dart';

/// Replace the body of this screen with your existing Note Smart home UI
/// (notes list, add-note button, etc). This file only shows where the
/// Settings entry point goes.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Smart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('আপনার নোট এখানে দেখাবে'),
      ),
    );
  }
}
