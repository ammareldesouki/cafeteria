import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/dio_handler.dart';

class FcmService {
  static final FcmService _instance = FcmService._();
  static FcmService get instance => _instance;

  FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  String? _currentToken;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Request permission
    final permission = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    log('FCM permission: ${permission.authorizationStatus}');

    // On iOS, explicitly wait for APNs token
    try {
      await _messaging.getAPNSToken();
    } catch (e) {
      log('APNs token not yet available: $e');
    }

    // Initialize local notifications channel
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // Listen for token refresh (fires once APNs token is ready on iOS)
    _messaging.onTokenRefresh.listen((token) {
      _currentToken = token;
      log('FCM token: $token');
      _registerToken();
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  String? get currentToken => _currentToken;

  /// Register the current FCM token with the backend (admin only).
  Future<void> registerToken() async {
    if (_currentToken != null) {
      await _registerToken();
      return;
    }
    // Retry multiple times with increasing delays
    for (final delay in [2, 4, 8]) {
      await Future.delayed(Duration(seconds: delay));
      try {
        _currentToken = await _messaging.getToken();
      } catch (_) {
        continue;
      }
      if (_currentToken != null) {
        await _registerToken();
        return;
      }
    }
    log('FCM token unavailable after retries. Will register on refresh.');
  }

  Future<void> _registerToken() async {
    if (_currentToken == null) return;
    try {
      await NetworkDioHandler().dio.post(
        '/admin/fcm-token',
        data: {'token': _currentToken},
      );
      log('FCM token registered with backend');
    } catch (e) {
      log('FCM token registration failed: $e');
    }
  }

  /// Unregister the token on logout.
  Future<void> unregisterToken() async {
    if (_currentToken == null) return;
    try {
      await NetworkDioHandler().dio.delete(
        '/admin/fcm-token',
        data: {'token': _currentToken},
      );
      log('FCM token unregistered');
    } catch (e) {
      log('FCM token unregister failed: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    log('FCM foreground: ${notification.title} — ${notification.body}');

    _notifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'scheduled_orders',
          'Scheduled Orders',
          channelDescription: 'Notifications for upcoming scheduled orders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
