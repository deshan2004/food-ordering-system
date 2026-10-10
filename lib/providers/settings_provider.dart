import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  String _currentLanguage = 'en'; // 'en' (English) or 'si' (සිංහල)

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get currentLanguage => _currentLanguage;
  bool get isSinhala => _currentLanguage == 'si';

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleLanguage() {
    _currentLanguage = _currentLanguage == 'en' ? 'si' : 'en';
    notifyListeners();
  }

  void setLanguage(String langCode) {
    if (langCode == 'en' || langCode == 'si') {
      _currentLanguage = langCode;
      notifyListeners();
    }
  }

  // Comprehensive Multi-Language Dictionary
  static final Map<String, Map<String, String>> _translations = {
    'app_title': {
      'en': 'Bonchi - Sri Lankan Food Ordering',
      'si': 'බොන්චි - ශ්‍රී ලාංකික ආහාර ඇණවුම් කිරීම',
    },
    'greeting_guest': {
      'en': 'Ayubowan, Guest!',
      'si': 'ආයුබෝවන්, අමුත්තා!',
    },
    'sub_greeting': {
      'en': "Bada ginida? Let's get you something tasty!",
      'si': 'බඩගිනිද? රසවත් කෑමක් ඇණවුම් කරමු!',
    },
    'tab_home': {
      'en': 'Home',
      'si': 'මුල් පිටුව',
    },
    'tab_favorites': {
      'en': 'Favorites',
      'si': 'ප්‍රියතම',
    },
    'tab_cart': {
      'en': 'My Cart',
      'si': 'කරත්තය',
    },
    'tab_profile': {
      'en': 'Profile',
      'si': 'ගිණුම',
    },
    'my_orders': {
      'en': 'My Orders & 1-Tap Re-Order',
      'si': 'මගේ ඇණවුම් සහ නැවත ඇණවුම්',
    },
    'order_again': {
      'en': 'Order Again ⚡',
      'si': 'නැවත ඇණවුම් කරන්න ⚡',
    },
    'reorder': {
      'en': 'Re-Order',
      'si': 'නැවත ඇණවුම්',
    },
    'view_cart': {
      'en': 'View Cart',
      'si': 'කරත්තය බලන්න',
    },
    'checkout': {
      'en': 'Checkout',
      'si': 'ගෙවීම් තහවුරු කිරීම',
    },
    'place_order': {
      'en': 'Place Order Now',
      'si': 'දැන් ඇණවුම් කරන්න',
    },
    'delivery_address': {
      'en': 'Delivery Address',
      'si': 'බෙදාහැරීමේ ලිපිනය',
    },
    'payment_method': {
      'en': 'Payment Method',
      'si': 'ගෙවීමේ ක්‍රමය',
    },
    'appearance': {
      'en': 'Dark Mode Theme',
      'si': 'අඳුරු තේමාව (Dark Mode)',
    },
    'appearance_subtitle': {
      'en': 'Switch between day and night mode',
      'si': 'දිවා සහ රාත්‍රී තේමා අතර මාරු වන්න',
    },
    'language': {
      'en': 'Language / භාෂාව',
      'si': 'භාෂාව / Language',
    },
    'view_coupons': {
      'en': 'View Coupons 🎟️',
      'si': 'කූපන් පත් බලන්න 🎟️',
    },
    'apply': {
      'en': 'Apply',
      'si': 'යොදන්න',
    },
    'clear_all': {
      'en': 'Clear All',
      'si': 'සියල්ල ඉවත් කරන්න',
    },
    'add_all_cart': {
      'en': 'Add All to Cart',
      'si': 'සියල්ල කරත්තයට එක් කරන්න',
    },
    'live_tracking': {
      'en': 'Live Order Tracking',
      'si': 'සජීවී ඇණවුම් සොයාගැනීම',
    },
    'logout': {
      'en': 'Log Out of Account',
      'si': 'ගිණුමෙන් ඉවත් වන්න',
    },
  };

  String tr(String key) {
    if (_translations.containsKey(key)) {
      return _translations[key]?[_currentLanguage] ?? _translations[key]?['en'] ?? key;
    }
    return key;
  }
}
