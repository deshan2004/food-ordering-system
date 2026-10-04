# 🍔 Bonchi - Sri Lankan Food Ordering & Delivery App

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Supported-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-green.style=for-the-badge)](LICENSE)

**Bonchi** is a modern, high-performance, and visually stunning mobile food ordering application built with **Flutter**, designed specifically for authentic Sri Lankan culinary experiences (Kottu, Rice & Curry, Short Eats, Biryani, and Tea Time snacks).

---

## ✨ Key Features

- 🎨 **Modern & Vibrant UI/UX**: Sleek dark & light theme accents, micro-animations, glassmorphism, and responsive design.
- 🍱 **Categorized Food Menu**: Quick filtering by categories such as *Rice & Curry*, *Kottu Mania*, *Short Eats*, *Biryani Feast*, and *Cafe & Milk*.
- 🌶️ **Customizable Spice Levels**: Choose spice preferences (Mild 🍃, Medium 🌶️, Nai Miris Hot 🔥) with dynamic price calculation.
- 🛒 **Smart Shopping Cart**: Quantity adjustments, dynamic subtotal & delivery fee calculation, promo code system, and item removal.
- 💳 **Seamless Checkout**: Multiple payment options (Cash on Delivery, Credit/Debit Card), address management, and order summary.
- 🛵 **Real-time Order Tracking**: Animated order status lifecycle (`Order Placed` ➔ `Preparing` ➔ `Out for Delivery` ➔ `Delivered`) with interactive driver details & countdown timers.
- ☁️ **Supabase Cloud Backend Integration**: Built-in support for Supabase Auth, PostgreSQL database storage, and real-time order tracking.
- 🔐 **User Authentication**: Secure Login & Sign Up flow with validation and user session state management using Provider.

---

## 🛠️ Technology Stack

- **Framework**: [Flutter SDK](https://flutter.dev)
- **Language**: [Dart](https://dart.dev)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Backend / Cloud DB**: [Supabase](https://supabase.com) (`supabase_flutter`)
- **Typography & Icons**: Google Fonts (Inter / Outfit) & Cupertino Icons

---

## 📁 Project Architecture & Directory Structure

```text
lib/
├── models/
│   ├── food_item.dart        # FoodItem & SpiceOption data models + JSON converters
│   └── user_model.dart       # User profile data model + JSON converters
├── providers/
│   ├── auth_provider.dart    # User authentication & session state
│   ├── cart_provider.dart    # Shopping cart management & checkout logic
│   ├── favorites_provider.dart # Favorites list state
│   └── order_provider.dart   # Order status tracking state
├── screens/
│   ├── main_navigation_screen.dart # Bottom navigation bar controller
│   ├── home_screen.dart      # Main dashboard, search & food list
│   ├── food_detail_screen.dart # Detailed food preview & customization
│   ├── cart_screen.dart      # Cart overview & promo codes
│   ├── checkout_screen.dart  # Delivery address & payment method
│   ├── order_tracking_screen.dart # Live order tracking & map animation
│   ├── favorites_screen.dart # Saved favorite foods
│   ├── login_screen.dart     # User login screen
│   └── signup_screen.dart    # User registration screen
├── services/
│   ├── food_service.dart     # Categories & mock data fallback
│   └── supabase_service.dart # Supabase Auth & PostgreSQL API client
└── theme/
    └── app_theme.dart        # Unified color palette, typography & styling
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19.0 or higher)
- [Dart SDK](https://dart.dev/get-dart)
- An active [Supabase Account](https://supabase.com) (Optional for cloud backend integration)

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/food-ordering-system.git
   cd food-ordering-system
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase Credentials (Optional)**
   Open `lib/services/supabase_service.dart` and add your Supabase credentials:
   ```dart
   static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

4. **Run the Application**
   ```bash
   # Run on iOS Simulator
   flutter run -d iphone

   # Run on Android Emulator
   flutter run -d android

   # Run on macOS Desktop
   flutter run -d macos
   ```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

⭐ **If you like this project, don't forget to give it a Star on GitHub!**
