import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  int _selectedTab = 0; // 0: Available Jobs, 1: Active Delivery, 2: Earnings & Wallet, 3: Rider Profile
  bool _isOnline = true;

  // Driver Profile State
  final String _driverName = 'Sumith Perera';
  String _driverPhone = '+94 77 123 4567';
  String _driverVehicle = 'ABF-8842 Red Bajaj RE Tuk-Tuk';
  final String _driverRating = '4.9';
  double _walletBalance = 5420.0;
  double _todayEarnings = 3850.0;
  final double _cashInHand = 2750.0;
  int _completedTripsToday = 8;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final availableJobs = orderProvider.availableDriverJobs;
    final acceptedJobs = orderProvider.myAcceptedDriverDeliveries;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            // Bonchi Mascot Brand Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/bonchi_logo.png',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.eco, color: AppTheme.primaryGreen, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Bonchi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryGreen,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          'RIDER',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0284C7),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$_driverName • $_driverVehicle',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Switch to Customer Demo Mode capsule button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => authProvider.setRole(UserRole.customer),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.swap_horiz_rounded, size: 14, color: AppTheme.primaryGreen),
                    SizedBox(width: 4),
                    Text(
                      'Customer App',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildSelectedTabContent(orderProvider, availableJobs, acceptedJobs),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _selectedTab,
            onTap: (index) => setState(() => _selectedTab = index),
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primaryGreen,
            unselectedItemColor: AppTheme.textSecondary,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: availableJobs.isNotEmpty,
                  label: Text('${availableJobs.length}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: AppTheme.primaryGreen,
                  child: const Icon(Icons.radar_outlined, size: 22),
                ),
                activeIcon: Badge(
                  isLabelVisible: availableJobs.isNotEmpty,
                  label: Text('${availableJobs.length}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: AppTheme.primaryGreen,
                  child: const Icon(Icons.radar_rounded, color: AppTheme.primaryGreen, size: 22),
                ),
                label: 'Nearby Jobs',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: acceptedJobs.isNotEmpty,
                  label: Text('${acceptedJobs.length}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: Colors.orange.shade700,
                  child: const Icon(Icons.navigation_outlined, size: 22),
                ),
                activeIcon: Badge(
                  isLabelVisible: acceptedJobs.isNotEmpty,
                  label: Text('${acceptedJobs.length}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: Colors.orange.shade700,
                  child: const Icon(Icons.navigation_rounded, color: AppTheme.primaryGreen, size: 22),
                ),
                label: 'Active Trip',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_outlined, size: 22),
                activeIcon: Icon(Icons.account_balance_wallet_rounded, color: AppTheme.primaryGreen, size: 22),
                label: 'Earnings',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded, size: 22),
                activeIcon: Icon(Icons.person_rounded, color: AppTheme.primaryGreen, size: 22),
                label: 'Rider Info',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineStatusBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _isOnline ? const Color(0xFF0F172A) : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isOnline ? const Color(0xFF22C55E) : Colors.redAccent,
              boxShadow: [
                BoxShadow(
                  color: (_isOnline ? const Color(0xFF22C55E) : Colors.redAccent).withValues(alpha: 0.6),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isOnline ? 'Rider Status: ONLINE & READY' : 'Rider Status: OFFLINE',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _isOnline ? 'Scanning nearby food orders' : 'Turn online to receive new food orders',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Transform.scale(
            scale: 0.82,
            child: Switch(
              value: _isOnline,
              activeColor: const Color(0xFF22C55E),
              onChanged: (val) {
                setState(() => _isOnline = val);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(val ? 'You are now Online! Receiving nearby orders.' : 'You went Offline.'),
                    backgroundColor: val ? AppTheme.primaryGreen : Colors.grey.shade800,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.95), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent(
    OrderProvider orderProvider,
    List<OrderModel> availableJobs,
    List<OrderModel> acceptedJobs,
  ) {
    switch (_selectedTab) {
      case 0:
        return _buildAvailableJobsTab(orderProvider, availableJobs);
      case 1:
        return _buildActiveDeliveriesTab(orderProvider, acceptedJobs);
      case 2:
        return _buildEarningsTab();
      case 3:
      default:
        return _buildRiderProfileTab();
    }
  }

  // -------------------------------------------------------------
  // TAB 1: AVAILABLE NEARBY JOBS
  // -------------------------------------------------------------
  Widget _buildAvailableJobsTab(OrderProvider orderProvider, List<OrderModel> availableJobs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Rider Status Card
          _buildOnlineStatusBanner(),

          const SizedBox(height: 12),

          // 2. 3 Quick Stat Cards
          Row(
            children: [
              _buildQuickStatCard('Nearby Jobs', '${availableJobs.length} Available', Icons.radar_rounded, const Color(0xFF0284C7)),
              const SizedBox(width: 10),
              _buildQuickStatCard("Today's Pay", 'Rs. ${_todayEarnings.toStringAsFixed(0)}', Icons.payments_rounded, AppTheme.primaryGreen),
              const SizedBox(width: 10),
              _buildQuickStatCard('Trips Done', '$_completedTripsToday Trips', Icons.task_alt_rounded, Colors.orange.shade700),
            ],
          ),

          const SizedBox(height: 18),

          // Section Heading
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nearby Delivery Jobs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -0.3),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${availableJobs.length} In Range',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (!_isOnline)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.power_settings_new_rounded, size: 54, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text(
                      'You are currently Offline',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Toggle the switch above to go Online and receive orders',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else if (availableJobs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.radar_rounded, size: 48, color: AppTheme.primaryGreen),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Scanning for Food Orders...',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'As soon as a customer orders from a hotel near Colombo 03, the pickup job will ping here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),
            )
          else
            ...availableJobs.map((order) => _buildJobCard(orderProvider, order)),

          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _buildJobCard(OrderProvider orderProvider, OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.95), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Pay badge & Order ID
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC).withValues(alpha: 0.8),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E7FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.orderId,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF3730A3)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${order.items.length} items • ${order.paymentMethod}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Earn Rs. ${order.driverEarningsLkr.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 1. Pickup: Restaurant
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.storefront_rounded, size: 16, color: Colors.orange),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                order.restaurantName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('1.1 km pickup', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.restaurantAddress,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Connecting dotted path
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 2,
                      height: 18,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),

                // 2. Drop-off: Customer
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on_rounded, size: 16, color: AppTheme.primaryGreen),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                order.customerName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('${order.distanceKm} km trip', style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.deliveryAddress,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // Action Buttons: View Route on Map & Accept Job
                Row(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0284C7),
                        side: const BorderSide(color: Color(0xFF0284C7)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onPressed: () => _showRouteMapDialog(context, order),
                      icon: const Icon(Icons.map_outlined, size: 16),
                      label: const Text('View Map', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          orderProvider.acceptDeliveryByDriver(
                            orderId: order.orderId,
                            driverName: _driverName,
                            driverVehicle: _driverVehicle,
                            driverPhone: _driverPhone,
                            driverRating: _driverRating,
                          );
                          setState(() => _selectedTab = 1); // Switch to Active Delivery tab
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Delivery accepted for ${order.orderId}! Switched to Active Trip.'),
                              backgroundColor: AppTheme.primaryGreen,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Accept Delivery Job', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 2: ACTIVE DELIVERY / TRIP PROGRESS
  // -------------------------------------------------------------
  Widget _buildActiveDeliveriesTab(OrderProvider orderProvider, List<OrderModel> acceptedJobs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Trip Progress',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -0.3),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${acceptedJobs.length} Ongoing',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (acceptedJobs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.moped_rounded, size: 50, color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Active Deliveries Right Now',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Head over to the "Nearby Jobs" tab to accept a waiting delivery order.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () => setState(() => _selectedTab = 0),
                      child: const Text('View Available Jobs', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )
          else
            ...acceptedJobs.map((order) => _buildActiveDeliveryCard(orderProvider, order)),

          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _buildActiveDeliveryCard(OrderProvider orderProvider, OrderModel order) {
    final isHeadingToRestaurant = order.status == OrderStatus.confirmed || order.status == OrderStatus.prepped;
    final isOnTheWayToCustomer = order.status == OrderStatus.onTheWay;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.45), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Trip Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.navigation_rounded, color: Color(0xFF22C55E), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      isHeadingToRestaurant ? 'PHASE 1: PICKUP AT HOTEL' : 'PHASE 2: DELIVER TO CUSTOMER',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                    ),
                  ],
                ),
                Text(
                  order.orderId,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Destination Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isHeadingToRestaurant ? Colors.orange.shade100 : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isHeadingToRestaurant ? Icons.restaurant_rounded : Icons.person_pin_circle_rounded,
                          color: isHeadingToRestaurant ? Colors.orange.shade800 : AppTheme.primaryGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isHeadingToRestaurant ? order.restaurantName : order.customerName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isHeadingToRestaurant ? order.restaurantAddress : order.deliveryAddress,
                              style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isHeadingToRestaurant ? 'Contact Hotel Kitchen' : 'Phone: ${order.customerPhone}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0284C7)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Order items list preview
                const Text('Items in this Delivery:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 6),
                ...order.items.map((i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('• ${i.quantity}x ${i.foodItem.name}', style: const TextStyle(fontSize: 12.5)),
                          Text('Rs. ${i.totalPriceLkr.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
                        ],
                      ),
                    )),

                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Customer Payment: ${order.paymentMethod}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF92400E))),
                      Text('Collect Rs. ${order.grandTotalLkr.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF92400E))),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Progress Step Button
                if (isHeadingToRestaurant) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        orderProvider.updateOrderStatus(order.orderId, OrderStatus.onTheWay);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Food picked up from hotel! Now navigating to customer address.'),
                            backgroundColor: AppTheme.primaryGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.takeout_dining_rounded, size: 20),
                      label: const Text('Confirm Food Picked Up from Hotel 🛍️', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ] else if (isOnTheWayToCustomer) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        orderProvider.updateOrderStatus(order.orderId, OrderStatus.delivered);
                        setState(() {
                          _walletBalance += order.driverEarningsLkr;
                          _todayEarnings += order.driverEarningsLkr;
                          _completedTripsToday += 1;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Order delivered! Rs. ${order.driverEarningsLkr.toStringAsFixed(0)} credited to rider wallet.'),
                            backgroundColor: AppTheme.primaryGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_rounded, size: 20),
                      label: const Text('Confirm Food Delivered & Settle Cash ✅', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 3: EARNINGS & WALLET BREAKDOWN
  // -------------------------------------------------------------
  Widget _buildEarningsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wallet Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('RIDER WALLET BALANCE', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    Icon(Icons.verified, color: Color(0xFF22C55E), size: 18),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Rs. ${_walletBalance.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Today's Earnings", style: TextStyle(color: Colors.white60, fontSize: 10)),
                            Text('Rs. ${_todayEarnings.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Trips Today', style: TextStyle(color: Colors.white60, fontSize: 10)),
                            Text('$_completedTripsToday Completed', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _showPayoutDialog,
                    icon: const Icon(Icons.account_balance_rounded, size: 18),
                    label: const Text('Withdraw Payout to Bank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),
          const Text('Earnings Breakdown (Today)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),

          _buildEarningsMetricTile(
            title: 'Base Delivery Pay',
            amount: 'Rs. 2,400',
            subtitle: '$_completedTripsToday trips × Rs. 300 base fee',
            icon: Icons.delivery_dining_rounded,
            color: const Color(0xFF0284C7),
          ),
          const SizedBox(height: 10),
          _buildEarningsMetricTile(
            title: 'Distance Allowances',
            amount: 'Rs. 950',
            subtitle: 'Kilometer allowances (> 2.5 km)',
            icon: Icons.alt_route_rounded,
            color: Colors.orange,
          ),
          const SizedBox(height: 10),
          _buildEarningsMetricTile(
            title: 'Customer Tips',
            amount: 'Rs. 500',
            subtitle: 'Generous food lovers tips',
            icon: Icons.volunteer_activism_rounded,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(height: 10),
          _buildEarningsMetricTile(
            title: 'Cash on Delivery Collected',
            amount: 'Rs. ${_cashInHand.toStringAsFixed(0)}',
            subtitle: 'Cash collected to be settled with Bonchi',
            icon: Icons.payments_outlined,
            color: Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsMetricTile({
    required String title,
    required String amount,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Text(amount, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color)),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 4: RIDER PROFILE & VEHICLE DETAILS
  // -------------------------------------------------------------
  Widget _buildRiderProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: const Color(0xFF0284C7).withValues(alpha: 0.15),
                      child: const Icon(Icons.person, size: 48, color: Color(0xFF0284C7)),
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
                        child: const Icon(Icons.verified, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(_driverName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
                    const SizedBox(width: 4),
                    Text('$_driverRating Rating • 142 Completed Trips', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                _buildProfileDetailRow('Vehicle Registration', _driverVehicle, Icons.two_wheeler_rounded),
                const SizedBox(height: 12),
                _buildProfileDetailRow('Contact Phone', _driverPhone, Icons.phone_rounded),
                const SizedBox(height: 12),
                _buildProfileDetailRow('License Verification', 'Verified Driver (Western Province)', Icons.verified_user_rounded),
                const SizedBox(height: 12),
                _buildProfileDetailRow('Settlement Bank', 'Commercial Bank •••• 4242', Icons.account_balance_rounded),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      side: const BorderSide(color: AppTheme.primaryGreen),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _showEditVehicleDialog,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Vehicle & Details', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailRow(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditVehicleDialog() {
    final vehicleCtrl = TextEditingController(text: _driverVehicle);
    final phoneCtrl = TextEditingController(text: _driverPhone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Edit Rider Vehicle Details', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: vehicleCtrl,
              decoration: const InputDecoration(labelText: 'Vehicle Number & Model', prefixIcon: Icon(Icons.two_wheeler)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Contact Phone', prefixIcon: Icon(Icons.phone)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                _driverVehicle = vehicleCtrl.text.trim();
                _driverPhone = phoneCtrl.text.trim();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vehicle details updated!'), backgroundColor: AppTheme.primaryGreen),
              );
            },
            child: const Text('Save Details'),
          ),
        ],
      ),
    );
  }

  void _showPayoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Withdraw Payout to Bank', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transfer your earnings to your linked bank account:',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.account_balance, color: AppTheme.primaryGreen),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Commercial Bank of Ceylon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Acc: 8004 •••• 9210 • Sumith P.', style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Amount: Rs. ${_walletBalance.toStringAsFixed(0)} (Instant IMFS)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryGreen),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white),
            onPressed: () {
              setState(() => _walletBalance = 0);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Withdrawal request approved! Funds transferred via CEFT.'),
                  backgroundColor: AppTheme.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Withdraw Now'),
          ),
        ],
      ),
    );
  }

  void _showRouteMapDialog(BuildContext context, OrderModel order) {
    final restaurantCoord = LatLng(order.restaurantLatitude, order.restaurantLongitude);
    final deliveryCoord = LatLng(
      order.destinationLatitude ?? 6.9015,
      order.destinationLongitude ?? 79.8560,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Job Route Preview: ${order.orderId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${order.restaurantName} ➔ ${order.deliveryAddress}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
            ),
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: restaurantCoord,
                  initialZoom: 13.5,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.foodordering.foodOrderingSystem',
                  ),
                  MarkerLayer(
                    markers: [
                      // Restaurant Marker
                      Marker(
                        point: restaurantCoord,
                        width: 50,
                        height: 50,
                        child: const Column(
                          children: [
                            Icon(Icons.storefront_rounded, color: Colors.orange, size: 34),
                          ],
                        ),
                      ),
                      // Delivery Destination Marker
                      Marker(
                        point: deliveryCoord,
                        width: 50,
                        height: 50,
                        child: const Column(
                          children: [
                            Icon(Icons.location_on_rounded, color: AppTheme.accentRed, size: 38),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close Map Preview', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
