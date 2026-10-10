import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../models/cart_item.dart';
import '../services/notification_service.dart';

class OrderProvider with ChangeNotifier {
  final List<OrderModel> _orders = [];

  OrderProvider() {
    // Orders list starts empty. Only populated when an order is actually placed by the user.
  }

  List<OrderModel> get orders => List.unmodifiable(_orders);

  OrderModel? get activeOrder {
    try {
      // Active order is any ongoing order or a freshly delivered order that hasn't been rated yet
      return _orders.firstWhere(
        (o) => o.status != OrderStatus.delivered || !o.isRated,
      );
    } catch (_) {
      return null;
    }
  }

  void submitOrderRatings({
    required String orderId,
    required double riderRating,
    required String riderFeedback,
    required double restaurantRating,
    required String restaurantFeedback,
  }) {
    final idx = _orders.indexWhere((o) => o.orderId == orderId);
    if (idx != -1) {
      _orders[idx].status = OrderStatus.delivered;
      _orders[idx].isRated = true;
      _orders[idx].riderRatingScore = riderRating;
      _orders[idx].riderFeedbackText = riderFeedback;
      _orders[idx].restaurantRatingScore = restaurantRating;
      _orders[idx].restaurantFeedbackText = restaurantFeedback;
      notifyListeners();
    }
  }

  void clearActiveOrder(String orderId) {
    final idx = _orders.indexWhere((o) => o.orderId == orderId);
    if (idx != -1) {
      _orders[idx].status = OrderStatus.delivered;
      _orders[idx].isRated = true;
      notifyListeners();
    }
  }

  List<OrderModel> get availableDriverJobs =>
      _orders.where((o) => !o.isDriverAssigned && o.status != OrderStatus.delivered).toList();

  List<OrderModel> get myAcceptedDriverDeliveries =>
      _orders.where((o) => o.isDriverAssigned && o.status != OrderStatus.delivered).toList();

  OrderModel placeOrder({
    required List<CartItem> items,
    required double subtotalLkr,
    required double deliveryFeeLkr,
    required double discountLkr,
    required double grandTotalLkr,
    required String deliveryAddress,
    String? customerName,
    String? customerPhone,
    String? paymentMethod,
    double? destinationLatitude,
    double? destinationLongitude,
    String? deliveryTimeOption,
  }) {
    final newOrder = OrderModel(
      orderId: '#BC-${(1000 + DateTime.now().millisecond % 9000).toString()}',
      items: List.from(items),
      subtotalLkr: subtotalLkr,
      deliveryFeeLkr: deliveryFeeLkr,
      discountLkr: discountLkr,
      grandTotalLkr: grandTotalLkr,
      deliveryAddress: deliveryAddress,
      customerName: customerName ?? 'Deshan Siriwardhana',
      customerPhone: customerPhone ?? '0781776315',
      paymentMethod: paymentMethod ?? 'Cash on Delivery',
      deliveryTimeOption: deliveryTimeOption ?? 'ASAP (20-25 min)',
      destinationLatitude: destinationLatitude,
      destinationLongitude: destinationLongitude,
      distanceKm: 3.5,
      driverEarningsLkr: (deliveryFeeLkr > 0 ? deliveryFeeLkr * 2.2 : 350.0).clamp(300.0, 750.0),
      orderTime: DateTime.now(),
      status: OrderStatus.confirmed,
      isDriverAssigned: false,
      riderName: 'Looking for nearby Rider...',
      riderVehicle: 'Assigning...',
    );

    _orders.insert(0, newOrder);
    notifyListeners();

    // Trigger System & In-App Notification (pops banner even if screen is locked)
    NotificationService.instance.showOrderNotification(
      orderId: newOrder.orderId,
      title: '🎉 Order Confirmed! (${newOrder.orderId})',
      body: 'Your delicious order has been received! The kitchen is preparing your dishes.',
      payload: newOrder.orderId,
    );

    // Async save to MySQL Database via PHP API
    _sendOrderToMySql(newOrder, items, grandTotalLkr, deliveryAddress);

    return newOrder;
  }

  void acceptDeliveryByDriver({
    required String orderId,
    required String driverName,
    required String driverVehicle,
    required String driverPhone,
    required String driverRating,
  }) {
    final idx = _orders.indexWhere((o) => o.orderId == orderId);
    if (idx != -1) {
      _orders[idx].isDriverAssigned = true;
      _orders[idx].riderName = driverName;
      _orders[idx].riderVehicle = driverVehicle;
      _orders[idx].riderPhone = driverPhone;
      _orders[idx].riderRating = driverRating;
      notifyListeners();

      NotificationService.instance.showOrderNotification(
        orderId: orderId,
        title: '🛵 Rider Assigned! ($driverName)',
        body: '$driverName on $driverVehicle is heading towards the restaurant to pick up your meal.',
        payload: orderId,
      );
    }
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final idx = _orders.indexWhere((o) => o.orderId == orderId);
    if (idx != -1) {
      _orders[idx].status = newStatus;
      if (newStatus == OrderStatus.onTheWay) {
        _orders[idx].estimatedMinsLeft = 10;
      } else if (newStatus == OrderStatus.delivered) {
        _orders[idx].estimatedMinsLeft = 0;
      }
      notifyListeners();

      String title = '';
      String body = '';
      if (newStatus == OrderStatus.prepped) {
        title = '🍳 Food Prepared & Packed!';
        body = 'The kitchen has finished cooking your meal at Pilawos. Packed fresh & ready!';
      } else if (newStatus == OrderStatus.onTheWay) {
        title = '🚀 Rider On The Way!';
        body = 'Your food has been picked up! Rider is speeding towards your location with hot food.';
      } else if (newStatus == OrderStatus.delivered) {
        title = '🍲 Order Delivered! Bon Appétit!';
        body = 'Your food has arrived safely. Enjoy your meal and don\'t forget to rate your rider!';
      }

      if (title.isNotEmpty) {
        NotificationService.instance.showOrderNotification(
          orderId: orderId,
          title: title,
          body: body,
          payload: orderId,
        );
      }
    }
  }

  Future<void> _sendOrderToMySql(OrderModel order, List<CartItem> items, double total, String address) async {
    try {
      final payload = {
        'order_id': order.orderId,
        'total_amount': total,
        'delivery_address': address,
        'payment_method': 'Cash on Delivery',
        'items': items.map((i) => {
          'id': i.foodItem.id,
          'name': i.foodItem.name,
          'quantity': i.quantity,
          'price': i.totalPriceLkr,
        }).toList(),
      };

      await http.post(
        Uri.parse('http://localhost/food_api/place_order.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
    } catch (e) {
      print('MySQL Order Sync Error: $e');
    }
  }
}
