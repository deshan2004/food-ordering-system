enum PaymentType {
  visa,
  mastercard,
  amex,
  applePay,
  cash,
}

class PaymentMethodModel {
  final String id;
  final String title;
  final String subtitle;
  final PaymentType type;
  final String? cardNumber;
  final String? cardHolder;
  final String? expiryDate;
  final String? cvv;
  final String? bankName;
  final bool isDefault;

  PaymentMethodModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.cardNumber,
    this.cardHolder,
    this.expiryDate,
    this.cvv,
    this.bankName,
    this.isDefault = false,
  });

  PaymentMethodModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    PaymentType? type,
    String? cardNumber,
    String? cardHolder,
    String? expiryDate,
    String? cvv,
    String? bankName,
    bool? isDefault,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      type: type ?? this.type,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolder: cardHolder ?? this.cardHolder,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      bankName: bankName ?? this.bankName,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
