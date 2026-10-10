import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_ordering_system/models/order.dart';
import 'package:food_ordering_system/models/cart_item.dart';
import 'package:food_ordering_system/models/food_item.dart';
import 'package:food_ordering_system/services/invoice_pdf_service.dart';

void main() {
  group('InvoicePdfService Tests', () {
    late OrderModel testOrder;

    setUp(() {
      testOrder = OrderModel(
        orderId: 'ORD-98214',
        items: [
          CartItem(
            id: 'item-1',
            foodItem: FoodItem(
              id: 'f1',
              name: 'Chicken Cheese Kottu',
              restaurantName: 'Pilawaos Night Kottu',
              category: 'Kottu',
              priceLkr: 1850.0,
              description: 'Chopped flatbread with shredded roast chicken and gooey mozzarella',
              imageUrl: 'assets/images/kottu.jpg',
              rating: 4.9,
              reviewCountText: '320 reviews',
              deliveryTime: '20-25 min',
              deliveryFeeLkr: 250.0,
            ),
            selectedSpiceLevel: SpiceOption(
              id: 'sp_1',
              name: 'Medium Spicy 🌶️',
              iconEmoji: '🌶️',
              extraPriceLkr: 50.0,
            ),
            quantity: 2,
          ),
          CartItem(
            id: 'item-2',
            foodItem: FoodItem(
              id: 'f2',
              name: 'Crispy Faluda Milk Shake',
              restaurantName: 'Pilawaos Night Kottu',
              category: 'Beverages',
              priceLkr: 650.0,
              description: 'Rose syrup milk with basil seeds and vanilla ice cream',
              imageUrl: 'assets/images/faluda.jpg',
              rating: 4.8,
              reviewCountText: '110 reviews',
              deliveryTime: '15 min',
              deliveryFeeLkr: 250.0,
            ),
            quantity: 1,
          ),
        ],
        subtotalLkr: 4450.0,
        deliveryFeeLkr: 250.0,
        discountLkr: 450.0,
        grandTotalLkr: 4250.0,
        customerName: 'Deshan Siriwardhana',
        customerPhone: '+94 77 987 6543',
        restaurantName: 'Pilawaos Night Kottu',
        deliveryAddress: 'No. 24, Flower Road, Colombo 07',
        paymentMethod: 'Bonchi Pay (Visa •••• 4242)',
        orderTime: DateTime(2026, 10, 10, 20, 30),
      );
    });

    test('generateReceiptPdf produces valid PDF bytes with header and content', () async {
      final pdfBytes = await InvoicePdfService.generateReceiptPdf(testOrder);

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.lengthInBytes, greaterThan(2000));

      // PDF files always begin with the %PDF- header magic bytes
      final headerStr = ascii.decode(pdfBytes.sublist(0, 5));
      expect(headerStr, equals('%PDF-'));
    });

    test('generateReceiptPdf handles orders with zero discount without error', () async {
      final zeroDiscountOrder = OrderModel(
        orderId: 'ORD-11111',
        items: testOrder.items,
        subtotalLkr: 4450.0,
        deliveryFeeLkr: 0.0,
        discountLkr: 0.0,
        grandTotalLkr: 4450.0,
        customerName: 'Kasun Bandara',
        orderTime: DateTime.now(),
      );

      final pdfBytes = await InvoicePdfService.generateReceiptPdf(zeroDiscountOrder);

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.lengthInBytes, greaterThan(1500));
      expect(ascii.decode(pdfBytes.sublist(0, 5)), equals('%PDF-'));
    });
  });
}
