import 'cart_item.dart';

enum OrderStatus {
  confirmed,
  prepped,
  onTheWay,
  delivered,
}

class OrderModel {
  final String orderId;
  final List<CartItem> items;
  final double subtotalLkr;
  final double deliveryFeeLkr;
  final double discountLkr;
  final double grandTotalLkr;
  final String deliveryAddress;
  final String restaurantAddress;
  final String riderName;
  final String riderRating;
  final String riderVehicle;
  final DateTime orderTime;
  OrderStatus status;
  final int estimatedMinsLeft;
  final String estimatedArrivalTime;
  final double? destinationLatitude;
  final double? destinationLongitude;

  OrderModel({
    required this.orderId,
    required this.items,
    required this.subtotalLkr,
    required this.deliveryFeeLkr,
    required this.discountLkr,
    required this.grandTotalLkr,
    this.deliveryAddress = 'Your Location • 42/1, Flower Road, Col 07',
    this.restaurantAddress = 'Pilawaos Night Kottu • Colombo 03',
    this.riderName = 'Sumith Perera',
    this.riderRating = '4.9',
    this.riderVehicle = 'ABF-8842  Red Tuk-Tuk',
    required this.orderTime,
    this.status = OrderStatus.onTheWay,
    this.estimatedMinsLeft = 12,
    this.estimatedArrivalTime = '8:42 PM',
    this.destinationLatitude,
    this.destinationLongitude,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.prepped:
        return 'Prepped';
      case OrderStatus.onTheWay:
        return 'On the Way';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }

  double get statusProgress {
    switch (status) {
      case OrderStatus.confirmed:
        return 0.33;
      case OrderStatus.prepped:
        return 0.66;
      case OrderStatus.onTheWay:
        return 0.85;
      case OrderStatus.delivered:
        return 1.0;
    }
  }
}
