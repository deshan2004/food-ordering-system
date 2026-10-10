import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final Map<String, List<ChatMessage>> _conversationMap = {};

  String _getKey(String orderId, ChatParticipantType type) => '${orderId}_${type.name}';

  List<ChatMessage> getMessages(String orderId, ChatParticipantType type, {String? riderName, String? restaurantName}) {
    final key = _getKey(orderId, type);
    if (!_conversationMap.containsKey(key)) {
      _initConversation(orderId, type, riderName: riderName, restaurantName: restaurantName);
    }
    return _conversationMap[key] ?? [];
  }

  void _initConversation(String orderId, ChatParticipantType type, {String? riderName, String? restaurantName}) {
    final key = _getKey(orderId, type);
    final now = DateTime.now().subtract(const Duration(minutes: 5));

    if (type == ChatParticipantType.rider) {
      _conversationMap[key] = [
        ChatMessage(
          id: 'msg_r_init',
          orderId: orderId,
          senderName: riderName ?? 'Sumith (Rider)',
          senderType: ChatParticipantType.rider,
          text: 'Hello! I have picked up your order and I\'m on the way to your location 🛵',
          timestamp: now,
          isCustomer: false,
        ),
      ];
    } else {
      _conversationMap[key] = [
        ChatMessage(
          id: 'msg_k_init',
          orderId: orderId,
          senderName: restaurantName ?? 'Kitchen Chef',
          senderType: ChatParticipantType.restaurant,
          text: 'Welcome to Bonchi! Your meal is being freshly prepared with care. Feel free to let us know any spice or dietary requests! 🍳',
          timestamp: now,
          isCustomer: false,
        ),
      ];
    }
  }

  void sendMessage({
    required String orderId,
    required ChatParticipantType recipientType,
    required String text,
    required String senderName,
    String? recipientName,
  }) {
    if (text.trim().isEmpty) return;

    final key = _getKey(orderId, recipientType);
    if (!_conversationMap.containsKey(key)) {
      _initConversation(orderId, recipientType);
    }

    final newMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      senderName: senderName,
      senderType: ChatParticipantType.customer,
      text: text.trim(),
      timestamp: DateTime.now(),
      isCustomer: true,
    );

    _conversationMap[key]!.add(newMsg);
    notifyListeners();

    // Simulate realistic response from Rider or Kitchen after 1.2s
    _simulateReply(orderId, recipientType, text.trim(), recipientName);
  }

  void _simulateReply(String orderId, ChatParticipantType recipientType, String customerQuery, String? recipientName) {
    Timer(const Duration(milliseconds: 1400), () {
      final key = _getKey(orderId, recipientType);
      final queryLower = customerQuery.toLowerCase();
      String replyText = '';

      if (recipientType == ChatParticipantType.rider) {
        final rName = recipientName ?? 'Sumith (Rider)';
        if (queryLower.contains('gate') || queryLower.contains('door') || queryLower.contains('outside')) {
          replyText = 'Understood! I will call you as soon as I pull up outside your gate 👍';
        } else if (queryLower.contains('change') || queryLower.contains('cash') || queryLower.contains('money')) {
          replyText = 'No problem at all! I have change ready for cash payment 💵';
        } else if (queryLower.contains('call') || queryLower.contains('phone')) {
          replyText = 'Sure thing, I\'ll give you a quick call upon arrival 📞';
        } else if (queryLower.contains('bell') || queryLower.contains('ring')) {
          replyText = 'Got it! I will NOT ring the bell, will just drop off and text you 🤫';
        } else {
          replyText = 'Got your message! ETA is about 10-15 minutes. See you soon! 🛵';
        }

        _conversationMap[key]?.add(ChatMessage(
          id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
          orderId: orderId,
          senderName: rName,
          senderType: ChatParticipantType.rider,
          text: replyText,
          timestamp: DateTime.now(),
          isCustomer: false,
        ));
      } else {
        final kName = recipientName ?? 'Kitchen Team';
        if (queryLower.contains('spicy') || queryLower.contains('chilli') || queryLower.contains('pepper')) {
          replyText = 'Noted! Our chef has adjusted the spice level according to your request 🌶️';
        } else if (queryLower.contains('cutlery') || queryLower.contains('spoon') || queryLower.contains('napkin')) {
          replyText = 'Sure! We have packed extra wooden cutlery and napkins for you 🍴';
        } else if (queryLower.contains('sauce') || queryLower.contains('gravy') || queryLower.contains('ketchup')) {
          replyText = 'Extra sauces and condiments have been added with compliments! ✨';
        } else {
          replyText = 'Thank you for reaching out! We are packing your freshly cooked meal now 🥡';
        }

        _conversationMap[key]?.add(ChatMessage(
          id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
          orderId: orderId,
          senderName: kName,
          senderType: ChatParticipantType.restaurant,
          text: replyText,
          timestamp: DateTime.now(),
          isCustomer: false,
        ));
      }

      notifyListeners();
    });
  }

  // Quick Preset message chips
  List<String> getPresetChips(ChatParticipantType type) {
    if (type == ChatParticipantType.rider) {
      return [
        'I\'m waiting at the gate 🚪',
        'Please call when you arrive 📞',
        'Leave food at the door 📦',
        'Please don\'t ring the bell 🤫',
        'Cash payment ready 💵',
        'Need change for Rs. 5,000 🪙',
      ];
    } else {
      return [
        'Please make it less spicy 🌿',
        'Make it extra spicy please 🌶️',
        'Include extra napkins & cutlery 🍴',
        'Add extra sauce please 🥣',
        'Please pack securely for delivery 🥡',
      ];
    }
  }
}
