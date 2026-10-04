import 'dart:async';
import 'package:flutter/foundation.dart';
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
    return newOrder;
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
