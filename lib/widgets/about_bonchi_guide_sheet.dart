import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class AboutBonchiGuideSheet extends StatefulWidget {
  const AboutBonchiGuideSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AboutBonchiGuideSheet(),
    );
  }

  @override
  State<AboutBonchiGuideSheet> createState() => _AboutBonchiGuideSheetState();
}

class _AboutBonchiGuideSheetState extends State<AboutBonchiGuideSheet> {
  int _activeStepIndex = 0;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;
    final isSi = settings.isSinhala;

    final steps = [
      _GuideStep(
        badge: 'Step 1 • පියවර 1',
        icon: Icons.restaurant_menu_rounded,
        iconColor: const Color(0xFF059669),
        titleEn: 'Browse & Customize Authentic Meals',
        titleSi: 'රසවත් කෑම තෝරා ඔබ කැමති පරිදි සකසන්න',
        descriptionEn:
            'Explore Sri Lanka\'s favorite street food, cloud kitchens, and restaurants. Customize spice levels (Mild, Regular, Extra Spicy 🌶️), portion sizes, and add custom notes for the chef.',
        descriptionSi:
            'කොත්තු, ලම්ප්‍රයිස්, රයිස් ඇන්ඩ් කරි වැනි ප්‍රියතම ආහාර තෝරා ගන්න. සැර ප්‍රමාණය (Spice Level 🌶️) සහ අමතර උපදෙස් කුස්සියට එකතු කරන්න.',
      ),
      _GuideStep(
        badge: 'Step 2 • පියවර 2',
        icon: Icons.confirmation_number_rounded,
        iconColor: const Color(0xFFFF9F0A),
        titleEn: 'Apply Promo Coupons & Save Money',
        titleSi: 'කූපන් කේත මගින් වට්ටම් සහ නොමිලේ බෙදාහැරීම්',
        descriptionEn:
            'Tap "View Coupons 🎟️" in your cart to apply codes like WELCOME250, SAVE20, or FREEDELIVERY for instant price cuts on your orders.',
        descriptionSi:
            'කරත්තයේ ඇති "View Coupons" ඔබා WELCOME250, SAVE20 හෝ FREEDELIVERY වැනි කූපන් කේත යොදා ක්ෂණික මිල අඩු කිරීම් ලබා ගන්න.',
      ),
      _GuideStep(
        badge: 'Step 3 • පියවර 3',
        icon: Icons.directions_bike_rounded,
        iconColor: const Color(0xFF3B82F6),
        titleEn: 'Live GPS Tracking & Instant Chat',
        titleSi: 'සජීවී GPS Tracking සහ Rider සමඟ Chat කිරීම',
        descriptionEn:
            'Watch your rider move in real-time on OpenStreetMap with live ETA countdowns. Chat directly with your rider or kitchen team for gate drop-offs.',
        descriptionSi:
            'ඔබගේ ඇණවුම රැගෙන එන ධාවකයා Map එක ඔස්සේ ගමන් කරන අයුරු සජීවීව බලන්න. ඕනෑම මොහොතක Rider සහ Kitchen සමඟ කෙලින්ම Chat කරන්න.',
      ),
      _GuideStep(
        badge: 'Step 4 • පියවර 4',
        icon: Icons.notifications_active_rounded,
        iconColor: const Color(0xFF8B5CF6),
        titleEn: 'Screen-Off Alerts & 1-Tap Re-Order',
        titleSi: 'Lock Screen Notifications සහ 1-Tap Re-Order',
        descriptionEn:
            'Phone locked or screen off? You will still receive audio chimes and banners for cooking, rider arrival, and chats! Re-order any previous meal in a single tap.',
        descriptionSi:
            'Phone screen එක off කර තැබුවද ශබ්දය සමඟ lock screen notifications ලැබේ. එමෙන්ම පෙර ඇණවුම් එක click එකකින් නැවත ඇණවුම් කළ හැක.',
      ),
      _GuideStep(
        badge: 'Step 5 • පියවර 5',
        icon: Icons.dark_mode_rounded,
        iconColor: const Color(0xFFEC4899),
        titleEn: 'Dark Mode & Bilingual (සිංහල 🇱🇰 / EN)',
        titleSi: 'Dark Mode සහ භාෂාව මාරු කිරීම',
        descriptionEn:
            'Switch effortlessly between sleek Obsidian Dark Mode and Light Mode, and experience the full application in English or සිංහල from your Profile screen.',
        descriptionSi:
            'ඔබගේ Profile පිටුවට ගොස් එක ක්ලික් එකකින් Dark Mode ක්‍රියාත්මක කරගත හැකි අතර, සම්පූර්ණ app එක සිංහලෙන් හෝ ඉංග්‍රීසියෙන් භාවිතා කළ හැක.',
      ),
    ];

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 25,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top pull indicator
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Sheet Header with Mascot
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/bonchi_logo.png',
                        width: 42,
                        height: 42,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isSi ? 'බොන්චි ගැන දැනගනිමු' : 'About Bonchi App',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'v1.0 🇱🇰',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isSi
                              ? 'ශ්‍රී ලංකාවේ ප්‍රමුඛතම ආහාර ඇණවුම් කිරීමේ අත්දැකීම'
                              : 'Sri Lanka\'s Hyperlocal Food & Cloud Kitchen Platform',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Intro Banner Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF064E3B), const Color(0xFF0F172A)]
                              : [const Color(0xFFECFDF5), const Color(0xFFF0FDF4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: AppTheme.primaryGreen, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isSi
                                  ? 'Bonchi යනු කොළඹ සහ තදාසන්න ප්‍රදේශවල උණුසුම් ආහාර වේගයෙන්ම ඔබේ නිවසටම ගෙන්වා දෙන නවීන ආහාර ඇණවුම් කිරීමේ යෙදුමයි.'
                                  : 'Bonchi connects food lovers with top local cloud kitchens & street food vendors with real-time tracking and zero delivery stress.',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Walkthrough Section Title
                    Row(
                      children: [
                        const Icon(Icons.explore_rounded, color: AppTheme.primaryGreen, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isSi ? 'මෙය ක්‍රියා කරන්නේ කෙසේද? (Quick Tour)' : 'How It Works (Quick App Tour)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Step Pills Indicator
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(steps.length, (idx) {
                          final isSelected = _activeStepIndex == idx;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _activeStepIndex = idx;
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryGreen
                                      : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primaryGreen
                                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      steps[idx].icon,
                                      size: 15,
                                      color: isSelected ? Colors.white : steps[idx].iconColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Step ${idx + 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Active Step Highlight Card
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        key: ValueKey<int>(_activeStepIndex),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: steps[_activeStepIndex].iconColor.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: steps[_activeStepIndex].iconColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    steps[_activeStepIndex].badge,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: steps[_activeStepIndex].iconColor,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: steps[_activeStepIndex].iconColor.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    steps[_activeStepIndex].icon,
                                    color: steps[_activeStepIndex].iconColor,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isSi ? steps[_activeStepIndex].titleSi : steps[_activeStepIndex].titleEn,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isSi
                                  ? steps[_activeStepIndex].descriptionSi
                                  : steps[_activeStepIndex].descriptionEn,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (_activeStepIndex > 0)
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppTheme.textSecondary,
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _activeStepIndex--;
                                      });
                                    },
                                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 13),
                                    label: Text(isSi ? 'පෙර පියවර' : 'Previous'),
                                  )
                                else
                                  const SizedBox.shrink(),
                                if (_activeStepIndex < steps.length - 1)
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: steps[_activeStepIndex].iconColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 0,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _activeStepIndex++;
                                      });
                                    },
                                    label: Text(
                                      isSi ? 'ඊළඟ පියවර' : 'Next Step',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Features Grid Cards
                    Text(
                      isSi ? 'Bonchi හි සුවිශේෂී අංග' : 'Core Highlights',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _buildHighlightRow(
                      icon: Icons.flash_on_rounded,
                      color: const Color(0xFFF59E0B),
                      title: isSi ? 'සුපිරි වේගවත් බෙදාහැරීම' : '20-25 Min Lightning Delivery',
                      desc: isSi ? 'උණු උණු කෑම කෙලින්ම ඔබේ දොරකඩට' : 'Fresh & steaming hot straight to your doorstep',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildHighlightRow(
                      icon: Icons.security_rounded,
                      color: const Color(0xFF10B981),
                      title: isSi ? 'ආරක්ෂිත ගෙවීම් ක්‍රම' : 'Cash On Delivery & Card Security',
                      desc: isSi ? 'අතට ලැබුණු පසු ගෙවීමේ පහසුකම' : 'Safe payment options with total transparency',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildHighlightRow(
                      icon: Icons.chat_rounded,
                      color: const Color(0xFF6366F1),
                      title: isSi ? 'සජීවී In-App Chat' : 'Direct Rider & Kitchen Chat',
                      desc: isSi ? 'ඇණවුම ලැබෙන තුරුම සජීවීව සම්බන්ධ වන්න' : 'Live two-way instant messaging with zero confusion',
                      isDark: isDark,
                    ),

                    const SizedBox(height: 24),

                    // Close & Start Ordering CTA
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.lunch_dining_rounded, size: 20),
                        label: Text(
                          isSi ? 'දැන්ම කෑම ඇණවුම් කරමු! 🍛' : 'Got it! Start Exploring Food 🍛',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightRow({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideStep {
  final String badge;
  final IconData icon;
  final Color iconColor;
  final String titleEn;
  final String titleSi;
  final String descriptionEn;
  final String descriptionSi;

  _GuideStep({
    required this.badge,
    required this.icon,
    required this.iconColor,
    required this.titleEn,
    required this.titleSi,
    required this.descriptionEn,
    required this.descriptionSi,
  });
}
