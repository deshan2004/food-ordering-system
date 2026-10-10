enum ChatParticipantType {
  customer,
  rider,
  restaurant,
}

class ChatMessage {
  final String id;
  final String orderId;
  final String senderName;
  final ChatParticipantType senderType;
  final String text;
  final DateTime timestamp;
  final bool isCustomer;

  ChatMessage({
    required this.id,
    required this.orderId,
    required this.senderName,
    required this.senderType,
    required this.text,
    required this.timestamp,
    required this.isCustomer,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'senderName': senderName,
      'senderType': senderType.name,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isCustomer': isCustomer,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    ChatParticipantType pType = ChatParticipantType.customer;
    if (json['senderType'] == 'rider') pType = ChatParticipantType.rider;
    if (json['senderType'] == 'restaurant') pType = ChatParticipantType.restaurant;

    return ChatMessage(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderType: pType,
      text: json['text'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isCustomer: json['isCustomer'] ?? true,
    );
  }
}
