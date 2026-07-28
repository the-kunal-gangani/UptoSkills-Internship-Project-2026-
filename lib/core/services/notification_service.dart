import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// NotificationService — OneSignal-based push notification handler.
///
/// Usage:
///   await NotificationService.instance.initialize();
///   Call syncDeviceToken() after every login to keep onesignal_id fresh.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    final appId = dotenv.env['ONESIGNAL_APP_ID'] ?? '';
    if (appId.isEmpty || appId == 'YOUR_ONESIGNAL_APP_ID') {
      debugPrint('[Notifications] OneSignal App ID not configured. Skipping.');
      return;
    }

    try {
      // Debug logs during development (remove in production)
      OneSignal.Debug.setLogLevel(OSLogLevel.none);

      // Initialize with App ID
      OneSignal.initialize(appId);

      // Request notification permission (shows system prompt on first launch)
      await OneSignal.Notifications.requestPermission(true);

      // Sync device token to Supabase
      await syncDeviceToken();

      // Re-sync whenever the subscription ID changes (reinstall, etc.)
      OneSignal.User.pushSubscription.addObserver((state) async {
        final newId = state.current.id;
        if (newId != null && newId.isNotEmpty) {
          debugPrint('[Notifications] Subscription ID changed: $newId');
          await _saveOnesignalId(newId);
        }
      });

      _initialized = true;
      debugPrint('[Notifications] OneSignal initialized successfully.');
    } catch (e) {
      debugPrint('[Notifications] Initialization failed: $e');
    }
  }

  /// Call this after every successful login to ensure onesignal_id is current.
  Future<void> syncDeviceToken() async {
    try {
      final subscriptionId = OneSignal.User.pushSubscription.id;
      if (subscriptionId == null || subscriptionId.isEmpty) {
        debugPrint('[Notifications] No subscription ID yet — will sync on observer.');
        return;
      }
      await _saveOnesignalId(subscriptionId);
    } catch (e) {
      debugPrint('[Notifications] syncDeviceToken failed: $e');
    }
  }

  Future<void> _saveOnesignalId(String onesignalId) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;

    try {
      final role = user.userMetadata?['role'] as String? ?? 'parent';
      final table = switch (role) {
        'teacher' => 'teachers',
        'admin'   => 'admins',
        _         => 'parents',
      };

      await client
          .from(table)
          .update({'onesignal_id': onesignalId})
          .eq('id', user.id);

      debugPrint('[Notifications] onesignal_id saved for $role (${user.id})');
    } catch (e) {
      debugPrint('[Notifications] Failed to save onesignal_id: $e');
    }
  }

  /// Sends a push notification directly to a specific device by OneSignal ID.
  /// Used to notify teachers when a new booking is made for them.
  Future<void> sendToUser({
    required String onesignalId,
    required String title,
    required String body,
  }) async {
    try {
      // Tag the external user so we can target by onesignal subscription ID.
      // We push a notification via the OneSignal in-app SDK by adding the
      // recipient as an alias and using the Flutter SDK notification API.
      // Note: Direct server-to-device push requires the REST API or an
      // Edge Function; here we use the in-app SDK's addTrigger approach
      // as a lightweight alternative — for production use a Supabase
      // Edge Function calling the OneSignal REST API.
      //
      // For now we log the intent so the booking flow is not blocked.
      debugPrint('[Notifications] Would notify $onesignalId: "$title" – $body');

      // TODO: Replace with a call to a Supabase Edge Function that uses the
      // OneSignal REST API to push to a specific subscription ID, e.g.:
      // await Supabase.instance.client.functions.invoke('send-notification', body: {
      //   'onesignal_id': onesignalId,
      //   'title': title,
      //   'body': body,
      // });
    } catch (e) {
      debugPrint('[Notifications] sendToUser failed: $e');
    }
  }
}
