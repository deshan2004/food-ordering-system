import 'package:flutter/material.dart';
import '../models/payment_method_model.dart';

class PaymentProvider extends ChangeNotifier {
  final List<PaymentMethodModel> _methods = [
    PaymentMethodModel(
      id: 'pm_visa_comm',
      title: 'Commercial Bank Visa',
      subtitle: '•••• •••• •••• 4242',
      type: PaymentType.visa,
      cardNumber: '4242 4242 4242 4242',
      cardHolder: 'Deshan Siriwardhana',
      expiryDate: '08/27',
      bankName: 'Commercial Bank',
      isDefault: true,
    ),
    PaymentMethodModel(
      id: 'pm_apple',
      title: 'Apple Pay',
      subtitle: 'Connected & Verified',
      type: PaymentType.applePay,
      isDefault: false,
    ),
    PaymentMethodModel(
      id: 'pm_cod',
      title: 'Cash on Delivery',
      subtitle: 'Pay rider in cash upon receiving food',
      type: PaymentType.cash,
      isDefault: false,
    ),
  ];

  List<PaymentMethodModel> get paymentMethods => List.unmodifiable(_methods);

  PaymentMethodModel? get defaultMethod =>
      _methods.firstWhere((m) => m.isDefault, orElse: () => _methods.first);

  void addPaymentMethod({
    required String bankName,
    required PaymentType type,
    required String cardNumber,
    required String cardHolder,
    required String expiryDate,
    required String cvv,
    bool setAsDefault = false,
  }) {
    final cleanDigits = cardNumber.replaceAll(RegExp(r'\s+'), '');
    final last4 = cleanDigits.length >= 4
        ? cleanDigits.substring(cleanDigits.length - 4)
        : (cleanDigits.isNotEmpty ? cleanDigits : '0000');
    final typeName = type == PaymentType.visa
        ? 'Visa'
        : type == PaymentType.mastercard
            ? 'Mastercard'
            : 'Amex';
    final title = '$bankName $typeName';
    final subtitle = '•••• •••• •••• $last4';
    final newId = 'pm_${DateTime.now().millisecondsSinceEpoch}';

    if (setAsDefault) {
      for (int i = 0; i < _methods.length; i++) {
        _methods[i] = _methods[i].copyWith(isDefault: false);
      }
    }

    final newMethod = PaymentMethodModel(
      id: newId,
      title: title,
      subtitle: subtitle,
      type: type,
      cardNumber: cardNumber,
      cardHolder: cardHolder,
      expiryDate: expiryDate,
      cvv: cvv,
      bankName: bankName,
      isDefault: setAsDefault || _methods.isEmpty,
    );

    // Insert right before Apple Pay and Cash on Delivery, or at top
    final insertIndex = _methods.indexWhere(
      (m) => m.type == PaymentType.applePay || m.type == PaymentType.cash,
    );
    if (insertIndex != -1) {
      _methods.insert(insertIndex, newMethod);
    } else {
      _methods.add(newMethod);
    }

    notifyListeners();
  }

  void setDefault(String id) {
    for (int i = 0; i < _methods.length; i++) {
      _methods[i] = _methods[i].copyWith(isDefault: _methods[i].id == id);
    }
    notifyListeners();
  }

  void removePaymentMethod(String id) {
    _methods.removeWhere((m) => m.id == id);
    if (_methods.isNotEmpty && !_methods.any((m) => m.isDefault)) {
      _methods[0] = _methods[0].copyWith(isDefault: true);
    }
    notifyListeners();
  }
}
