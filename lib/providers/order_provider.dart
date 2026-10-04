import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../models/cart_item.dart';
import '../services/food_service.dart';

class OrderProvider with ChangeNotifier {
  late final List<OrderModel> _orders;
  Timer? _statusSimulationTimer;

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
      return _orders.firstWhere(
        (o) => o.status != OrderStatus.delivered,
      );
    } catch (_) {
      return _orders.isNotEmpty ? _orders.first : null;
    }
  }

  OrderModel placeOrder({
    required List<CartItem> items,
    required double subtotalLkr,
    required double deliveryFeeLkr,
    required double discountLkr,
    required double grandTotalLkr,
    required String deliveryAddress,
  }) {
    final newOrder = OrderModel(
      orderId: '#BC-${(1000 + DateTime.now().millisecond % 9000).toString()}',
      items: List.from(items),
      subtotalLkr: subtotalLkr,
      deliveryFeeLkr: deliveryFeeLkr,
      discountLkr: discountLkr,
      grandTotalLkr: grandTotalLkr,
      deliveryAddress: deliveryAddress,
      orderTime: DateTime.now(),
      status: OrderStatus.confirmed,
    );

    _orders.insert(0, newOrder);
    _startStatusSimulation(newOrder.orderId);
    notifyListeners();

    // Async save to MySQL Database via PHP API
    _sendOrderToMySql(newOrder, items, grandTotalLkr, deliveryAddress);

    return newOrder;
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

  void _startStatusSimulation(String orderId) {
    _statusSimulationTimer?.cancel();
    
    _statusSimulationTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      int index = _orders.indexWhere((o) => o.orderId == orderId);
      if (index >= 0) {
        final currentStatus = _orders[index].status;
        if (currentStatus == OrderStatus.confirmed) {
          _orders[index].status = OrderStatus.prepped;
          notifyListeners();
        } else if (currentStatus == OrderStatus.prepped) {
          _orders[index].status = OrderStatus.onTheWay;
          notifyListeners();
        } else if (currentStatus == OrderStatus.onTheWay) {
          _orders[index].status = OrderStatus.delivered;
          notifyListeners();
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _statusSimulationTimer?.cancel();
    super.dispose();
  }
}
