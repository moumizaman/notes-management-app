import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// AppsPro subscription integration for Note Smart.
///
/// IMPORTANT (security):
/// - Only the `publishable_key` belongs in the mobile app. Never put the
///   `secret_key` here — it must live on a server, because it can create
///   subscribers, unsubscribe them, and verify webhooks.
/// - Because of that, this file only calls the *no-auth* customer routes:
///     /s/{url_slug}/otp/request , /s/{url_slug}/otp/verify   (login + subscribe)
///     https://appspro.dev/unsubscribe                        (public unsubscribe page)
///   It does NOT call /api/v1/sdk/subscribe, /unsubscribe, /status, /verify —
///   those need the secret_key and belong on a backend.
class AppsProService {
  AppsProService._();
  static final AppsProService instance = AppsProService._();

  static const String baseUrl = 'https://api.appspro.dev';

  // --- Your app's credentials ---
  static const String publishableKey = 'pk_3001a546103f76bb13f29b8b';
  static const String appId = '050de6c7-1d6b-450c-aace-065c21bd9ca6';

  // TODO: paste your url_slug here (AppsPro dashboard -> your app -> Checkout URL,
  // it's the 10-character code after appspro.dev/s/). This is required for
  // /s/{url_slug}/otp/request and /otp/verify.
  static const String urlSlug = 'PASTE_YOUR_URL_SLUG_HERE';

  // ---- local session keys ----
  static const _kSubscribed = 'is_subscribed';
  static const _kLoggedIn = 'is_logged_in';
  static const _kPhone = 'saved_phone';
  static const _kSubscriberId = 'subscriber_id';

  // ---------------- OTP: request + verify (used for BOTH first-time
  // subscribe and phone verification during login) ----------------

  Future<String> requestOtp(String phone) async {
    final res = await http.post(
      Uri.parse('$baseUrl/s/$urlSlug/otp/request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200 || data['reference_no'] == null) {
      throw Exception(data['status_detail'] ?? 'OTP পাঠানো যায়নি, আবার চেষ্টা করুন');
    }
    return data['reference_no'] as String;
  }

  /// Returns true if verification succeeded and saves the session locally.
  Future<bool> verifyOtp({
    required String referenceNo,
    required String otp,
    required String phone,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/s/$urlSlug/otp/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'reference_no': referenceNo, 'otp': otp}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;

    final ok = res.statusCode == 200 &&
        (data['status_code'] == 'S1000' ||
            (data['subscription_status']?.toString().toUpperCase() == 'REGISTERED'));

    if (ok) {
      await _saveSession(
        phone: phone,
        subscriberId: data['subscriber_id']?.toString() ?? '',
      );
    }
    return ok;
  }

  Future<void> _saveSession({required String phone, required String subscriberId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSubscribed, true);
    await prefs.setBool(_kLoggedIn, true);
    await prefs.setString(_kPhone, phone);
    await prefs.setString(_kSubscriberId, subscriberId);
  }

  // ---------------- Local login (no OTP) — used after Logout ----------------

  /// After logout we keep `is_subscribed` + the phone number, so the user
  /// can log back in with just their phone number, no OTP.
  Future<bool> loginWithSavedPhone(String enteredPhone) async {
    final prefs = await SharedPreferences.getInstance();
    final subscribed = prefs.getBool(_kSubscribed) ?? false;
    final savedPhone = prefs.getString(_kPhone) ?? '';
    if (subscribed && savedPhone.isNotEmpty && _normalize(savedPhone) == _normalize(enteredPhone)) {
      await prefs.setBool(_kLoggedIn, true);
      return true;
    }
    return false;
  }

  String _normalize(String phone) => phone.replaceAll(RegExp(r'[^0-9]'), '').replaceFirst(RegExp(r'^880'), '0');

  // ---------------- Session state ----------------

  Future<bool> isSubscribed() async =>
      (await SharedPreferences.getInstance()).getBool(_kSubscribed) ?? false;

  Future<bool> isLoggedIn() async =>
      (await SharedPreferences.getInstance()).getBool(_kLoggedIn) ?? false;

  Future<String?> savedPhone() async =>
      (await SharedPreferences.getInstance()).getString(_kPhone);

  /// Logout: leaves the app, keeps subscription so next login skips OTP.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, false);
  }

  /// Unsubscribe: clears everything, next time the user must subscribe +
  /// verify OTP again from scratch. Call this AFTER the user finishes the
  /// public unsubscribe flow (see UnsubscribeScreen).
  Future<void> clearSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSubscribed, false);
    await prefs.setBool(_kLoggedIn, false);
    await prefs.remove(_kPhone);
    await prefs.remove(_kSubscriberId);
  }
}
