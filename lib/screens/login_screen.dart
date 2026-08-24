import 'package:flutter/material.dart';
import '../services/appspro_service.dart';
import 'otp_screen.dart';
import 'notes_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _continue() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 11) {
      setState(() => _error = 'সঠিক ফোন নম্বর দিন (01XXXXXXXXX)');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final service = AppsProService.instance;

    // If this phone matches an already-subscribed, previously logged-out
    // account on this device, skip OTP entirely.
    final loggedInLocally = await service.loginWithSavedPhone(phone);
    if (loggedInLocally) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const NotesScreen()),
        (route) => false,
      );
      return;
    }

    // Otherwise this is a new subscriber (or a different phone) -> OTP flow.
    try {
      final referenceNo = await service.requestOtp(phone);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpScreen(phone: phone, referenceNo: referenceNo),
        ),
      );
    } catch (e) {
      setState(() => _error = 'লগইন ব্যর্থ হয়েছে, আবার চেষ্টা করুন');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('লগইন')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'আপনার ফোন নম্বর দিন',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 14,
              decoration: InputDecoration(
                hintText: '01XXXXXXXXX',
                errorText: _error,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4834D4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _loading ? null : _continue,
                child: _loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('পরবর্তী', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
