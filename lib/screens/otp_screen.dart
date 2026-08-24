import 'package:flutter/material.dart';
import '../services/appspro_service.dart';
import 'home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String referenceNo;
  const OtpScreen({super.key, required this.phone, required this.referenceNo});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  late String _referenceNo;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _referenceNo = widget.referenceNo;
  }

  Future<void> _verify() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      setState(() => _error = 'OTP কোডটি দিন');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final ok = await AppsProService.instance.verifyOtp(
      referenceNo: _referenceNo,
      otp: otp,
      phone: widget.phone,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      // Login/verification failed -> stay here, let them try again.
      setState(() => _error = 'OTP সঠিক নয়, আবার চেষ্টা করুন');
      _otpController.clear();
    }
  }

  Future<void> _resend() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final newRef = await AppsProService.instance.requestOtp(widget.phone);
      setState(() => _referenceNo = newRef);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('নতুন OTP পাঠানো হয়েছে')),
        );
      }
    } catch (_) {
      setState(() => _error = 'OTP পাঠানো যায়নি, আবার চেষ্টা করুন');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP ভেরিফিকেশন')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Text(
              '${widget.phone} নম্বরে পাঠানো OTP কোডটি দিন',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, letterSpacing: 6),
              decoration: InputDecoration(
                hintText: '------',
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
                onPressed: _loading ? null : _verify,
                child: _loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('ভেরিফাই করুন', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loading ? null : _resend,
              child: const Text('আবার OTP পাঠান'),
            ),
          ],
        ),
      ),
    );
  }
}
