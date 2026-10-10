import 'package:flutter_test/flutter_test.dart';
import 'package:food_ordering_system/services/notification_service.dart';

void main() {
  group('NotificationService Unit Tests', () {
    late NotificationService service;

    setUp(() {
      service = NotificationService.instance;
      service.clearHistory();
    });

    test('Initial history is empty and unreadCount is 0', () {
      expect(service.notificationHistory.isEmpty, true);
      expect(service.unreadCount, 0);
    });

    test('showOrderNotification records item in history and increments unreadCount', () async {
      await service.showOrderNotification(
        orderId: '#BC-1234',
        title: '🎉 Order Confirmed!',
        body: 'Your food is being prepared.',
      );

      expect(service.notificationHistory.length, 1);
      expect(service.unreadCount, 1);
      expect(service.notificationHistory.first.title, '🎉 Order Confirmed!');
      expect(service.notificationHistory.first.type, NotificationType.orderUpdate);
      expect(service.notificationHistory.first.payload, '#BC-1234');
      expect(service.notificationHistory.first.isRead, false);
    });

    test('showChatNotification records chat item with sender and orderId payload', () async {
      await service.showChatNotification(
        senderName: 'Kamal (Rider)',
        message: 'I am at your gate!',
        orderId: '#BC-5678',
      );

      expect(service.notificationHistory.length, 1);
      final item = service.notificationHistory.first;
      expect(item.title, '💬 Kamal (Rider)');
      expect(item.body, 'I am at your gate!');
      expect(item.type, NotificationType.chatMessage);
      expect(item.payload, '#BC-5678');
    });

    test('markAllAsRead sets isRead to true for all notifications', () async {
      await service.showOrderNotification(
        orderId: '#BC-1',
        title: 'Alert 1',
        body: 'Body 1',
      );
      await service.showChatNotification(
        senderName: 'Rider',
        message: 'Hello',
        orderId: '#BC-1',
      );

      expect(service.unreadCount, 2);

      service.markAllAsRead();

      expect(service.unreadCount, 0);
      expect(service.notificationHistory.every((n) => n.isRead), true);
    });

    test('clearHistory empties the notification history', () async {
      await service.showOrderNotification(
        orderId: '#BC-1',
        title: 'Alert 1',
        body: 'Body 1',
      );
      expect(service.notificationHistory.isNotEmpty, true);

      service.clearHistory();
      expect(service.notificationHistory.isEmpty, true);
      expect(service.unreadCount, 0);
    });

    test('onNotificationReceived stream emits new notification events', () async {
      final emittedItems = <AppNotificationItem>[];
      final subscription = service.onNotificationReceived.listen((item) {
        emittedItems.add(item);
      });

      await service.showOrderNotification(
        orderId: '#BC-STREAM',
        title: 'Stream Alert',
        body: 'Stream test body',
      );

      await Future.delayed(const Duration(milliseconds: 50));
      expect(emittedItems.length, 1);
      expect(emittedItems.first.title, 'Stream Alert');

      await subscription.cancel();
    });
  });
}
