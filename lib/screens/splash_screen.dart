import 'package:flutter/material.dart';
import '../services/appspro_service.dart';
import 'subscribe_screen.dart';
import 'login_screen.dart';
import 'notes_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final service = AppsProService.instance;
    final subscribed = await service.isSubscribed();
    final loggedIn = await service.isLoggedIn();

    Widget next;
    if (!subscribed) {
      next = const SubscribeScreen();
    } else if (!loggedIn) {
      next = const LoginScreen();
    } else {
      next = const NotesScreen();
    }

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => next));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF4834D4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt_rounded, color: Colors.white, size: 72),
            SizedBox(height: 16),
            Text(
              'Note Smart',
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
