import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/appspro_service.dart';
import 'splash_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AppsProService.instance.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }

  Future<void> _unsubscribe(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unsubscribe করবেন?'),
        content: const Text(
          'Unsubscribe করলে অ্যাপের ফিচারগুলো আর ব্যবহার করতে পারবেন না। আবার '
          'ব্যবহার করতে চাইলে নতুন করে সাবস্ক্রাইব ও OTP ভেরিফিকেশন করতে হবে।',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('বাতিল')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Unsubscribe')),
        ],
      ),
    );
    if (confirmed != true) return;

    // AppsPro's public unsubscribe page is OTP-gated and needs no secret
    // key, so it's safe to open from the app. It opens in the browser;
    // when the user comes back we clear local subscription state so the
    // app asks them to subscribe again next launch.
    final uri = Uri.parse('https://appspro.dev/unsubscribe');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    await AppsProService.instance.clearSubscription();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('সেটিংস')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            subtitle: const Text('পরের বার শুধু ফোন নম্বর দিয়েই লগইন করতে পারবেন'),
            onTap: () => _logout(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.cancel_outlined, color: Colors.red),
            title: const Text('Unsubscribe', style: TextStyle(color: Colors.red)),
            subtitle: const Text('আবার ব্যবহার করতে হলে নতুন করে সাবস্ক্রাইব করতে হবে'),
            onTap: () => _unsubscribe(context),
          ),
        ],
      ),
    );
  }
}
