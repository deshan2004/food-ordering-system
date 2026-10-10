import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_ordering_system/providers/settings_provider.dart';

void main() {
  group('SettingsProvider Dark Mode & Multi-language Tests', () {
    late SettingsProvider settings;

    setUp(() {
      settings = SettingsProvider();
    });

    test('Initial settings default to Light mode and English language', () {
      expect(settings.themeMode, ThemeMode.light);
      expect(settings.isDarkMode, false);
      expect(settings.currentLanguage, 'en');
      expect(settings.isSinhala, false);
    });

    test('Toggling theme switches between light and dark mode', () {
      bool notified = false;
      settings.addListener(() => notified = true);

      settings.toggleTheme();
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.isDarkMode, true);
      expect(notified, true);

      notified = false;
      settings.toggleTheme();
      expect(settings.themeMode, ThemeMode.light);
      expect(settings.isDarkMode, false);
      expect(notified, true);
    });

    test('setThemeMode sets the exact ThemeMode requested', () {
      settings.setThemeMode(ThemeMode.dark);
      expect(settings.themeMode, ThemeMode.dark);

      settings.setThemeMode(ThemeMode.system);
      expect(settings.themeMode, ThemeMode.system);
    });

    test('Toggling language switches between English and Sinhala', () {
      settings.toggleLanguage();
      expect(settings.currentLanguage, 'si');
      expect(settings.isSinhala, true);

      settings.toggleLanguage();
      expect(settings.currentLanguage, 'en');
      expect(settings.isSinhala, false);
    });

    test('setLanguage validates allowed language codes', () {
      settings.setLanguage('si');
      expect(settings.currentLanguage, 'si');

      // Invalid language code should not change current language
      settings.setLanguage('fr');
      expect(settings.currentLanguage, 'si');

      settings.setLanguage('en');
      expect(settings.currentLanguage, 'en');
    });

    test('tr(key) returns accurate English and Sinhala translations', () {
      // English check
      expect(settings.tr('tab_home'), 'Home');
      expect(settings.tr('tab_cart'), 'My Cart');
      expect(settings.tr('checkout'), 'Checkout');
      expect(settings.tr('appearance'), 'Dark Mode Theme');

      // Switch to Sinhala
      settings.setLanguage('si');
      expect(settings.tr('tab_home'), 'මුල් පිටුව');
      expect(settings.tr('tab_cart'), 'කරත්තය');
      expect(settings.tr('checkout'), 'ගෙවීම් තහවුරු කිරීම');
      expect(settings.tr('appearance'), 'අඳුරු තේමාව (Dark Mode)');
    });

    test('tr(key) returns key if translation is missing', () {
      expect(settings.tr('unknown_key_xyz'), 'unknown_key_xyz');
    });
  });
}
