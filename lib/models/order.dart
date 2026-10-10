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
  final String restaurantName;
  final double restaurantLatitude;
  final double restaurantLongitude;
  String riderName;
  String riderRating;
  String riderVehicle;
  String riderPhone;
  final String customerName;
  final String customerPhone;
  final String paymentMethod;
  final DateTime orderTime;
  OrderStatus status;
  int estimatedMinsLeft;
  String estimatedArrivalTime;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final double distanceKm;
  final double driverEarningsLkr;
  bool isDriverAssigned;

  OrderModel({
    required this.orderId,
    required this.items,
    required this.subtotalLkr,
    required this.deliveryFeeLkr,
    required this.discountLkr,
    required this.grandTotalLkr,
    this.deliveryAddress = 'Your Location • 42/1, Flower Road, Col 07',
    this.restaurantAddress = 'Pilawaos Night Kottu • Galle Road, Colombo 03',
    this.restaurantName = 'Pilawaos Night Kottu',
    this.restaurantLatitude = 6.9085,
    this.restaurantLongitude = 79.8512,
    this.riderName = 'Sumith Perera',
    this.riderRating = '4.9',
    this.riderVehicle = 'ABF-8842 Red Bajaj Tuk-Tuk',
    this.riderPhone = '+94 77 123 4567',
    this.customerName = 'Deshan Siriwardhana',
    this.customerPhone = '0781776315',
    this.paymentMethod = 'Cash on Delivery',
    required this.orderTime,
    this.status = OrderStatus.onTheWay,
    this.estimatedMinsLeft = 12,
    this.estimatedArrivalTime = '8:42 PM',
    this.destinationLatitude,
    this.destinationLongitude,
    this.distanceKm = 3.8,
    this.driverEarningsLkr = 380.0,
    this.isDriverAssigned = true,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.prepped:
        return 'Ready for Pickup';
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
