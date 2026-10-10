import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../models/cart_item.dart';
import '../services/food_service.dart';

class OrderProvider with ChangeNotifier {
  late final List<OrderModel> _orders;

  OrderProvider() {
    // Initial mock order as shown in Bonchi screenshot 3
    final sampleItem = CartItem(
      id: 'init_1',
      foodItem: FoodService.mockFoodItems.first,
      selectedSpiceLevel: FoodService.bonchiSpiceOptions[2], // Nai Miris Hot
      quantity: 1,
    );

    _orders = [
      OrderModel(
        orderId: '#BC-8492',
        items: [sampleItem],
        subtotalLkr: 2600.0,
        deliveryFeeLkr: 150.0,
        discountLkr: 0.0,
        grandTotalLkr: 2750.0,
        deliveryAddress: 'Your Location • 42/1, Flower Road, Col 07',
        restaurantAddress: 'Pilawaos Night Kottu • Colombo 03',
        riderName: 'Sumith Perera',
        riderRating: '4.9',
        riderVehicle: 'ABF-8842  Red Tuk-Tuk',
        orderTime: DateTime.now().subtract(const Duration(minutes: 10)),
        status: OrderStatus.onTheWay,
        estimatedMinsLeft: 12,
        estimatedArrivalTime: '8:42 PM',
      ),
    ];
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
