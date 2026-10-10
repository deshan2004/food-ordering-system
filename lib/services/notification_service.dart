import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum NotificationType {
  orderUpdate,
  chatMessage,
  promo,
}

class AppNotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  final String? payload;
  bool isRead;

  AppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.payload,
    this.isRead = false,
  });
}

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // In-app notifications history list & stream for reactive UI toasts/inbox
  final List<AppNotificationItem> _inAppHistory = [];
  final StreamController<AppNotificationItem> _notificationStreamController =
      StreamController<AppNotificationItem>.broadcast();

  Stream<AppNotificationItem> get onNotificationReceived =>
      _notificationStreamController.stream;

  List<AppNotificationItem> get notificationHistory =>
      List.unmodifiable(_inAppHistory);

  int get unreadCount => _inAppHistory.where((n) => !n.isRead).length;

  void markAllAsRead() {
    for (var n in _inAppHistory) {
      n.isRead = true;
    }
  }

  void clearHistory() {
    _inAppHistory.clear();
  }

  /// Initialize local notification plugins with Android and iOS channels
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Android Initialization
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      // iOS / macOS Initialization with Alert, Badge & Sound permissions
      const DarwinInitializationSettings darwinSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _localNotificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
        },
      );

      // Create high-importance channel on Android for heads-up & lock screen alerts
      final androidPlatform = _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlatform != null) {
        await androidPlatform.createNotificationChannel(
          const AndroidNotificationChannel(
            'bonchi_orders_channel',
            'Bonchi Order & Delivery Updates',
            description:
                'Critical alerts for order placement, kitchen prep, rider transit, and chat messages',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            showBadge: true,
          ),
        );

        // Request Android 13+ POST_NOTIFICATIONS permission
        await androidPlatform.requestNotificationsPermission();
      }

      // Request iOS notification permissions
      final iOSPlatform = _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iOSPlatform != null) {
        await iOSPlatform.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('NotificationService init error (fallback mode): $e');
    }
  }

  /// Show high-priority OS Notification for Order Status
  /// (Pops banner on phone screen even if app is in background or screen is locked)
  Future<void> showOrderNotification({
    required String orderId,
    required String title,
    required String body,
    String? payload,
  }) async {
    final item = AppNotificationItem(
      id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: NotificationType.orderUpdate,
      payload: payload ?? orderId,
    );

    _recordInApp(item);

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'bonchi_orders_channel',
        'Bonchi Order & Delivery Updates',
        channelDescription: 'Real-time order tracking notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/launcher_icon',
        visibility: NotificationVisibility.public, // Visible on Lock Screen
        ticker: 'Bonchi Order Update',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await _localNotificationsPlugin.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload ?? orderId,
      );
    } catch (e) {
      debugPrint('Error dispatching OS order notification: $e');
    }
  }

  /// Show OS Notification when Rider or Kitchen sends a message
  Future<void> showChatNotification({
    required String senderName,
    required String message,
    required String orderId,
  }) async {
    final title = '💬 $senderName';
    final body = message;

    final item = AppNotificationItem(
      id: 'chat_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: NotificationType.chatMessage,
      payload: orderId,
    );

    _recordInApp(item);

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'bonchi_orders_channel',
        'Bonchi Order & Delivery Updates',
        channelDescription: 'Order chat messages',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/launcher_icon',
        visibility: NotificationVisibility.public,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await _localNotificationsPlugin.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: details,
        payload: orderId,
      );
    } catch (e) {
      debugPrint('Error dispatching OS chat notification: $e');
    }
  }

  void _recordInApp(AppNotificationItem item) {
    _inAppHistory.insert(0, item);
    if (_inAppHistory.length > 50) {
      _inAppHistory.removeLast();
    }
    _notificationStreamController.add(item);
  }
}
