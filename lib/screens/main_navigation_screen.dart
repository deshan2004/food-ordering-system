import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'cart_screen.dart';
import 'order_tracking_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'restaurant_dashboard_screen.dart';
import 'driver_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';
import 'map_location_picker_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/avatar_image_helper.dart';
import '../widgets/payment_sheets.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    // Route based on User Role from MySQL Database
    if (user != null) {
      if (user.role == UserRole.restaurant) {
        return const RestaurantDashboardScreen();
      }
      if (user.role == UserRole.driver) {
        return const DriverDashboardScreen();
      }
      if (user.role == UserRole.admin) {
        return const AdminDashboardScreen();
      }
    }

    final cart = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final activeOrder = orderProvider.activeOrder;

    final List<Widget> screens = [
      HomeScreen(
        onNavigateTab: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      const FavoritesScreen(),
      (cart.totalItemCount == 0 && activeOrder != null)
          ? OrderTrackingScreen(order: activeOrder)
          : CartScreen(
              onExploreTap: () {
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
      _buildProfileScreen(context),
    ];

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primaryGreen,
            unselectedItemColor: AppTheme.textSecondary,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.home_outlined, size: 22),
                    if (_currentIndex == 0)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                activeIcon: const Icon(Icons.home, color: AppTheme.primaryGreen, size: 22),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.search, size: 22),
                activeIcon: Icon(Icons.search, color: AppTheme.primaryGreen, size: 22),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: cart.totalItemCount > 0,
                  label: Text('${cart.totalItemCount}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: AppTheme.accentAmber,
                  child: const Icon(Icons.receipt_long_outlined, size: 22),
                ),
                activeIcon: Badge(
                  isLabelVisible: cart.totalItemCount > 0,
                  label: Text('${cart.totalItemCount}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: AppTheme.accentAmber,
                  child: const Icon(Icons.receipt_long, color: AppTheme.primaryGreen, size: 22),
                ),
                label: 'Orders',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline, size: 22),
                activeIcon: Icon(Icons.person, color: AppTheme.primaryGreen, size: 22),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileScreen(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    if (!auth.isAuthenticated || user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Account', style: TextStyle(fontWeight: FontWeight.bold)),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline, size: 64, color: AppTheme.primaryGreen),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome to Bonchi',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Log in or create an account to save your delivery addresses, view order history, and collect reward points!',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text('Log In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      side: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    child: const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final orderProvider = Provider.of<OrderProvider>(context);
    final favProvider = Provider.of<FavoritesProvider>(context);
    final activeOrder = orderProvider.activeOrder;

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'My Profile',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () => _showEditProfileDialog(context, auth),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.lightBorder),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_outlined, color: AppTheme.primaryGreen, size: 15),
                    SizedBox(width: 5),
                    Text(
                      'Edit',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            // Live Active Order Tracking Banner if present
            if (activeOrder != null)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderTrackingScreen(order: activeOrder),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDCFCE7), Color(0xFFF0FDF4)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.4)),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primaryGreen.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.two_wheeler, color: AppTheme.primaryGreen, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Live Order ${activeOrder.orderId}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppTheme.textPrimary),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('TRACK', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${activeOrder.statusText} • ${activeOrder.estimatedMinsLeft} mins left',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.primaryGreen),
                    ],
                  ),
                ),
              ),

            // Premium User Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _showPhotoPickerOptions(context, auth),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryGreen, Color(0xFF10B981)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryGreen.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 34,
                            backgroundImage: getAvatarImageProvider(user.avatarUrl),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, color: Color(0xFF0284C7), size: 16),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, size: 13, color: AppTheme.textMuted),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                user.email,
                                style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 13, color: AppTheme.textMuted),
                            const SizedBox(width: 5),
                            Text(
                              user.phone,
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Quick Stats Metric Row
            Row(
              children: [
                _buildStatPill('Reward Points', '${user.rewardsPoints}', Icons.stars_rounded, AppTheme.starYellow),
                const SizedBox(width: 10),
                _buildStatPill('Orders Placed', '${orderProvider.orders.length}', Icons.receipt_long_rounded, const Color(0xFF3B82F6)),
                const SizedBox(width: 10),
                _buildStatPill('Saved Favs', '${favProvider.favoriteIds.length}', Icons.favorite_rounded, const Color(0xFFEF4444)),
              ],
            ),
            const SizedBox(height: 16),

            // VIP Bonchi Rewards Luxury Banner Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                    Color(0xFF334155),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text(
                              'Bonchi Rewards Club',
                              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(width: 6),
                            Text(
                              '• GOLD',
                              style: TextStyle(color: Color(0xFFFBBF24), fontSize: 11, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${user.rewardsPoints} Points Available',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () => _showRedeemDialog(context, user),
                    child: const Text('Redeem', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 1: Account & Location
            _buildSectionHeader('ACCOUNT & LOCATION'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.location_on_rounded,
                    title: 'Delivery Address',
                    subtitle: user.address,
                    iconBgColor: const Color(0xFFDCFCE7),
                    iconColor: AppTheme.primaryGreen,
                    onTap: () async {
                      final res = await Navigator.push<LocationResult>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MapLocationPickerScreen(
                            initialLatitude: user.latitude,
                            initialLongitude: user.longitude,
                            initialAddress: user.address,
                          ),
                        ),
                      );
                      if (res != null) {
                        auth.updateProfile(
                          address: res.formattedAddress,
                          latitude: res.latitude,
                          longitude: res.longitude,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Address updated: ${res.formattedAddress}'),
                              backgroundColor: AppTheme.primaryGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 64, endIndent: 16),
                  _buildMenuTile(
                    icon: Icons.swap_horiz_rounded,
                    title: 'Switch User Role (Demo)',
                    subtitle: 'Switch between Customer, Restaurant & Driver',
                    iconBgColor: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFD97706),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user.role.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB45309),
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFFB45309)),
                        ],
                      ),
                    ),
                    onTap: () => _showRoleDemoModal(context, auth),
                  ),
                  const Divider(height: 1, indent: 64, endIndent: 16),
                  _buildMenuTile(
                    icon: Icons.payment_rounded,
                    title: 'Payment Methods',
                    subtitle: 'Saved cards & digital wallets',
                    iconBgColor: const Color(0xFFE0E7FF),
                    iconColor: const Color(0xFF4F46E5),
                    onTap: () => _showPaymentMethodsSheet(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 2: Preferences & Help
            _buildSectionHeader('PREFERENCES & SUPPORT'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notification Preferences',
                    subtitle: 'Offers, order updates & alerts',
                    iconBgColor: const Color(0xFFECFDF5),
                    iconColor: AppTheme.primaryGreen,
                    onTap: () => _showNotificationsSheet(context),
                  ),
                  const Divider(height: 1, indent: 64, endIndent: 16),
                  _buildMenuTile(
                    icon: Icons.headset_mic_rounded,
                    title: 'Help & Customer Support',
                    subtitle: '24/7 Live chat & hotline assistance',
                    iconBgColor: const Color(0xFFF0FDF4),
                    iconColor: const Color(0xFF059669),
                    onTap: () => _showSupportSheet(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button (Styled with soft red and proper spacing)
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.red.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accentRed,
                  backgroundColor: const Color(0xFFFEF2F2),
                  side: const BorderSide(color: Color(0xFFFECACA), width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _showLogoutConfirmation(context, auth),
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text(
                  'Log Out of Account',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // App Version Footer Tag
            const Center(
              child: Text(
                'Bonchi Food Delivery • v1.0.0 (Build 42)',
                style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 110), // Crucial clearance above the floating bottom navigation bar!
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppTheme.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? iconBgColor,
    Widget? trailing,
  }) {
    final color = iconColor ?? AppTheme.primaryGreen;
    final bg = iconBgColor ?? color.withValues(alpha: 0.1);

    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppTheme.textPrimary),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider auth) {
    final user = auth.currentUser;
    if (user == null) return;

    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Edit Profile Details', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  _showPhotoPickerOptions(context, auth);
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: getAvatarImageProvider(user.avatarUrl),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showPhotoPickerOptions(context, auth);
              },
              child: const Text(
                'Change Photo',
                style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white),
            onPressed: () {
              auth.updateProfile(
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: AppTheme.primaryGreen),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }


  void _showLogoutConfirmation(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out of your Bonchi account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed, foregroundColor: Colors.white),
            onPressed: () {
              auth.logout();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showRoleDemoModal(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select User Role (MySQL Demo)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Easily test Customer, Restaurant, Driver, and Admin interfaces:',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            _buildRoleOption(ctx, auth, 'Customer UI', 'Browse & order food', Icons.shopping_bag, UserRole.customer),
            _buildRoleOption(ctx, auth, 'Restaurant Manager', 'View live orders & kitchen status', Icons.restaurant, UserRole.restaurant),
            _buildRoleOption(ctx, auth, 'Delivery Driver (Rider)', 'Pickup & deliver orders', Icons.two_wheeler, UserRole.driver),
            _buildRoleOption(ctx, auth, 'Super Admin', 'Manage MySQL food items & sales', Icons.admin_panel_settings, UserRole.admin),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption(BuildContext ctx, AuthProvider auth, String title, String subtitle, IconData icon, UserRole role) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
        child: Icon(icon, color: AppTheme.primaryGreen),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      onTap: () async {
        Navigator.pop(ctx);
        if (auth.currentUser != null) {
          auth.setRole(role);
        } else {
          String demoEmail = 'customer@bonchi.lk';
          if (role == UserRole.restaurant) demoEmail = 'restaurant@bonchi.lk';
          if (role == UserRole.driver) demoEmail = 'driver@bonchi.lk';
          if (role == UserRole.admin) demoEmail = 'admin@bonchi.lk';
          await auth.login(email: demoEmail, password: 'password123');
        }
        setState(() {});
      },
    );
  }

  void _showRedeemDialog(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.starYellow.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.stars_rounded, color: AppTheme.starYellow, size: 24),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bonchi Rewards Club', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    Text('Available Balance: ${user.rewardsPoints} Points', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Available Rewards & Vouchers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppTheme.textSecondary)),
            const SizedBox(height: 10),
            _buildVoucherItem(
              title: 'LKR 500 Discount Coupon',
              code: 'BONCHI500',
              points: 150,
              userPoints: user.rewardsPoints,
              icon: Icons.local_offer_rounded,
              color: AppTheme.primaryGreen,
              onRedeem: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Coupon BONCHI500 redeemed! Applied to your next order.'),
                    backgroundColor: AppTheme.primaryGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildVoucherItem(
              title: 'Free Delivery on 3 Orders',
              code: 'FREESHIP3',
              points: 100,
              userPoints: user.rewardsPoints,
              icon: Icons.two_wheeler_rounded,
              color: const Color(0xFF3B82F6),
              onRedeem: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Free delivery perk activated!'),
                    backgroundColor: AppTheme.primaryGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildVoucherItem(
              title: 'Free Garlic Bread with Meal',
              code: 'FREEGARLIC',
              points: 75,
              userPoints: user.rewardsPoints,
              icon: Icons.fastfood_rounded,
              color: const Color(0xFFF59E0B),
              onRedeem: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Voucher FREEGARLIC added to your checkout!'),
                    backgroundColor: AppTheme.primaryGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherItem({
    required String title,
    required String code,
    required int points,
    required int userPoints,
    required IconData icon,
    required Color color,
    required VoidCallback onRedeem,
  }) {
    final canRedeem = userPoints >= points;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                const SizedBox(height: 2),
                Text('$points Points • Code: $code', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canRedeem ? color : Colors.grey.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: canRedeem ? onRedeem : null,
            child: Text(canRedeem ? 'Claim' : 'Locked', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodsSheet(BuildContext context) {
    showPaymentMethodsSheet(context);
  }

  void _showPhotoPickerOptions(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_a_photo_rounded, color: AppTheme.primaryGreen, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Change Profile Photo',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      Text(
                        'Take a photo, pick from gallery, or choose avatar',
                        style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: const Color(0xFFF8FAFC),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppTheme.primaryGreen, size: 20),
                ),
                title: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Capture a new photo with camera', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.textMuted),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  try {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 800,
                      maxHeight: 800,
                      imageQuality: 85,
                    );
                    if (picked != null) {
                      auth.updateProfile(avatarUrl: picked.path);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Profile photo updated from camera!'),
                            backgroundColor: AppTheme.primaryGreen,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      final isMissing = e.toString().contains('MissingPluginException');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isMissing
                                ? 'Native plugin update: Please STOP & re-run (flutter run) the app. Opening avatar picker...'
                                : 'Could not open camera: $e',
                          ),
                          backgroundColor: isMissing ? Colors.orange.shade800 : Colors.red.shade700,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                      if (isMissing) {
                        _showPresetAvatarsDialog(context, auth);
                      }
                    }
                  }
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: const Color(0xFFF8FAFC),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF0284C7), size: 20),
                ),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Select a picture from photo library', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.textMuted),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  try {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 800,
                      maxHeight: 800,
                      imageQuality: 85,
                    );
                    if (picked != null) {
                      auth.updateProfile(avatarUrl: picked.path);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Profile photo updated successfully!'),
                            backgroundColor: AppTheme.primaryGreen,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      final isMissing = e.toString().contains('MissingPluginException');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isMissing
                                ? 'Native plugin update: Please STOP & re-run (flutter run) the app. Opening avatar picker...'
                                : 'Could not open gallery: $e',
                          ),
                          backgroundColor: isMissing ? Colors.orange.shade800 : Colors.red.shade700,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                      if (isMissing) {
                        _showPresetAvatarsDialog(context, auth);
                      }
                    }
                  }
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: const Color(0xFFF8FAFC),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Icon(Icons.face_retouching_natural_rounded, color: Color(0xFFF59E0B), size: 20),
                ),
                title: const Text('Choose Avatar Preset', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Pick from curated high-quality avatars', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.textMuted),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showPresetAvatarsDialog(context, auth);
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: const Color(0xFFF8FAFC),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Icon(Icons.link_rounded, color: Color(0xFF8B5CF6), size: 20),
                ),
                title: const Text('Enter Web Image URL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Paste a web image link directly', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.textMuted),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showImageUrlDialog(context, auth);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPresetAvatarsDialog(BuildContext context, AuthProvider auth) {
    final avatarPresets = [
      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
      'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=200&q=80',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
      'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=200&q=80',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Choose Foodie Avatar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: avatarPresets.length,
            itemBuilder: (ctx, i) {
              final url = avatarPresets[i];
              final isSelected = auth.currentUser?.avatarUrl == url;
              return GestureDetector(
                onTap: () {
                  auth.updateProfile(avatarUrl: url);
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Avatar updated successfully!'),
                      backgroundColor: AppTheme.primaryGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(url),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }

  void _showImageUrlDialog(BuildContext context, AuthProvider auth) {
    final urlController = TextEditingController(text: auth.currentUser?.avatarUrl ?? '');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Image Web Link', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Direct Image URL (https://...)',
                prefixIcon: Icon(Icons.link),
                hintText: 'https://...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final trimmed = urlController.text.trim();
              if (trimmed.isNotEmpty) {
                auth.updateProfile(avatarUrl: trimmed);
              }
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Avatar link updated!'),
                  backgroundColor: AppTheme.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Notification Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Choose alerts you want to receive from Bonchi', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppTheme.primaryGreen,
                  title: const Text('Live Order Tracking Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Instant updates when rider picks up or arrives', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  value: true,
                  onChanged: (val) {},
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppTheme.primaryGreen,
                  title: const Text('Exclusive Food Promos & Deals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Weekly meal discounts and promo code alerts', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  value: true,
                  onChanged: (val) {},
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppTheme.primaryGreen,
                  title: const Text('SMS Confirmation Messages', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('OTP login and receipt delivery via SMS', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  value: true,
                  onChanged: (val) {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSupportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('24/7 Customer Care & Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Our dedicated support team in Colombo is here to help', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: const Color(0xFFF8FAFC),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFDCFCE7),
                child: Icon(Icons.support_agent_rounded, color: AppTheme.primaryGreen),
              ),
              title: const Text('Live Chat with Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Average response time: under 2 mins', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Starting live chat session...'), backgroundColor: AppTheme.primaryGreen),
                );
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: const Color(0xFFF8FAFC),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE0E7FF),
                child: Icon(Icons.call_rounded, color: Color(0xFF4F46E5)),
              ),
              title: const Text('Call Customer Hotline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('+94 11 234 5678 (Toll Free in Sri Lanka)', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 8),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: const Color(0xFFF8FAFC),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFEF3C7),
                child: Icon(Icons.email_outlined, color: Color(0xFFD97706)),
              ),
              title: const Text('Email Support Team', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('support@bonchi.lk', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
}
