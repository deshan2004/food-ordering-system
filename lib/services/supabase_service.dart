import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/food_item.dart';
import '../models/user_model.dart';

class SupabaseService {
  // Replace these credentials with your Supabase Project Settings ➔ API values
  static const String supabaseUrl = 'https://YOUR_SUPABASE_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  static SupabaseClient get client => Supabase.instance.client;

  // Initialize Supabase in main.dart
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Fetch Food Items from Supabase Table
  static Future<List<FoodItem>> getFoodItems() async {
    try {
      final data = await client.from('food_items').select();
      return (data as List).map((json) => FoodItem.fromJson(json)).toList();
    } catch (e) {
      print('Supabase getFoodItems error: $e');
      return [];
    }
  }

  // Register User with Supabase Auth
  static Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final AuthResponse res = await client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone': phone},
      );

      if (res.user != null) {
        return UserModel(
          id: res.user!.id,
          name: name,
          email: email,
          phone: phone,
        );
      }
      return null;
    } catch (e) {
      print('Supabase SignUp error: $e');
      rethrow;
    }
  }

  // Login User with Supabase Auth
  static Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse res = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        final meta = res.user!.userMetadata ?? {};
        return UserModel(
          id: res.user!.id,
          name: meta['name'] ?? email.split('@').first,
          email: email,
          phone: meta['phone'] ?? '',
        );
      }
      return null;
    } catch (e) {
      print('Supabase SignIn error: $e');
      rethrow;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}
