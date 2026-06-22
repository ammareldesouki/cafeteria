import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_handler.dart';

class FcmService {
  static final FcmService _instance = FcmService._();
  static FcmService get instance => _instance;

  FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// High-importance channel (plays the default bell sound). The channelId
  /// MUST match what the backend sends in `android.notification.channelId`.
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Order Notifications',
    description: 'New orders and upcoming scheduled orders',
    importance: Importance.high,
    playSound: true,
  );

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

    // Create the Android channel up-front so its sound/importance are applied.
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // On iOS, show notifications (with sound) even while the app is foreground.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
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
    // Delete any stale cached token (e.g. from a previous Firebase project)
    // so getToken() below generates a fresh one tied to the current project.
    // Safe: deleteToken() only invalidates this device's token server-side.
    try {
      await _messaging.deleteToken();
    } catch (_) {
      // Ignore — offline or already deleted.
    }
    // Retry getToken() with increasing delays
    for (final delay in [0, 2, 4, 8]) {
      if (delay > 0) await Future.delayed(Duration(seconds: delay));
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
      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString('locale_code') ?? 'en';
      await NetworkDioHandler().dio.post(
        '/fcm-token',
        data: {'token': _currentToken, 'lang': lang},
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
        '/fcm-token',
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

    // iOS already shows the banner + sound in the foreground via
    // setForegroundNotificationPresentationOptions, so showing a local
    // notification here too would double it. Android needs the manual show.
    if (Platform.isIOS) return;

    _notifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
      ),
    );
  }
}
