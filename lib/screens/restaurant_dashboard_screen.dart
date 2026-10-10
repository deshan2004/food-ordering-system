import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';

class RestaurantDashboardScreen extends StatefulWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  State<RestaurantDashboardScreen> createState() => _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen> {
  int _selectedTab = 0; // 0: Live Orders, 1: Earnings & Wallet, 2: Menu Stock, 3: Hotel Profile
  bool _isKitchenOpen = true;

  // Restaurant State
  final String _restaurantName = 'Pilawaos Grand Hotel';
  final String _restaurantAddress = 'No 142, Galle Road, Colombo 03';
  final String _restaurantPhone = '+94 11 257 8899';
  final double _todaySales = 42800.0;
  double _walletBalance = 38520.0; // 90% net after platform fee
  final int _completedOrdersToday = 14;

  final Map<String, bool> _stockStatus = {
    'Bonchi Special Seafood Kottu': true,
    'Chicken Cheese Kottu': true,
    'Sri Lankan Lamprais Special': true,
    'Crispy Pol Roti with Lunu Miris': true,
    'Faluda Royal Deluxe': true,
  };

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final activeOrders = orderProvider.orders.where((o) => o.status != OrderStatus.delivered).toList();
    final deliveredOrders = orderProvider.orders.where((o) => o.status == OrderStatus.delivered).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.soup_kitchen_rounded, color: Colors.orange, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kitchen Live Manager',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppTheme.textPrimary),
                ),
                Text(
                  '$_restaurantName • Colombo 03',
                  style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Switch to Customer Demo Mode shortcut
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            onPressed: () {
              authProvider.setRole(UserRole.customer);
            },
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: const Text('Customer App', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Kitchen Status Banner
          _buildKitchenStatusBanner(),

          // Navigation Tabs
          _buildNavigationSegment(),

          // Tab Content
          Expanded(
            child: _buildSelectedTabContent(orderProvider, activeOrders, deliveredOrders),
          ),
        ],
      ),
    );
  }

  Widget _buildKitchenStatusBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _isKitchenOpen ? const Color(0xFF0F172A) : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isKitchenOpen ? const Color(0xFF22C55E) : Colors.amber,
                  boxShadow: [
                    BoxShadow(
                      color: (_isKitchenOpen ? const Color(0xFF22C55E) : Colors.amber).withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isKitchenOpen ? 'Kitchen Status: OPEN & ACCEPTING' : 'Kitchen Status: BUSY / PAUSED',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                  Text(
                    _isKitchenOpen ? 'Live orders will pop up instantly for food prep' : 'Orders temporarily paused for rush hour',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _isKitchenOpen,
            activeColor: const Color(0xFF22C55E),
            onChanged: (val) {
              setState(() => _isKitchenOpen = val);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(val ? 'Kitchen is now Open for customer orders!' : 'Kitchen paused.'),
                  backgroundColor: val ? AppTheme.primaryGreen : Colors.grey.shade800,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationSegment() {
    final tabs = [
      {'title': 'Live Orders', 'icon': Icons.soup_kitchen_rounded},
      {'title': 'Sales & Wallet', 'icon': Icons.account_balance_wallet_rounded},
      {'title': 'Menu Stock', 'icon': Icons.restaurant_menu_rounded},
      {'title': 'Hotel Info', 'icon': Icons.storefront_rounded},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange.shade700 : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tabs[index]['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        tabs[index]['title'] as String,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSelectedTabContent(
    OrderProvider orderProvider,
    List<OrderModel> activeOrders,
    List<OrderModel> deliveredOrders,
  ) {
    switch (_selectedTab) {
      case 0:
        return _buildLiveOrdersTab(orderProvider, activeOrders);
      case 1:
        return _buildRestaurantFinanceTab(deliveredOrders);
      case 2:
        return _buildMenuStockTab();
      case 3:
      default:
        return _buildHotelInfoTab();
    }
  }

  // -------------------------------------------------------------
  // TAB 1: KITCHEN LIVE ORDERS
  // -------------------------------------------------------------
  Widget _buildLiveOrdersTab(OrderProvider orderProvider, List<OrderModel> activeOrders) {
    if (activeOrders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_outline, size: 48, color: Colors.orange.shade700),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kitchen is All Caught Up! 🎉',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'No pending food orders to cook right now. Incoming orders will pop up here with sound alert.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: activeOrders.length,
      itemBuilder: (context, index) {
        final order = activeOrders[index];
        return _buildKitchenOrderCard(orderProvider, order);
      },
    );
  }

  Widget _buildKitchenOrderCard(OrderProvider orderProvider, OrderModel order) {
    final isNew = order.status == OrderStatus.confirmed;
    final isPrepping = order.status == OrderStatus.prepped;
    final isPickedUp = order.status == OrderStatus.onTheWay;

    Color statusBadgeColor = isNew
        ? Colors.red.shade700
        : isPrepping
            ? Colors.orange.shade700
            : AppTheme.primaryGreen;

    String statusText = isNew
        ? 'NEW ORDER • START COOKING'
        : isPrepping
            ? 'COOKING IN PROGRESS'
            : 'PICKED UP BY RIDER';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      order.orderId,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusBadgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(color: statusBadgeColor, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Rs. ${order.grandTotalLkr.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.primaryGreen),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer & Delivery Address
                Row(
                  children: [
                    const Icon(Icons.person_pin_circle, size: 18, color: AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${order.customerName} • ${order.deliveryAddress}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Food Items Ticket
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('KITCHEN PREP TICKET:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF92400E))),
                      const SizedBox(height: 6),
                      ...order.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade700,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${item.quantity}x',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      item.foodItem.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                    ),
                                  ],
                                ),
                                if (item.selectedSpiceLevel != null)
                                  Text(
                                    item.selectedSpiceLevel!.name,
                                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.deepOrange),
                                  ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Assigned Driver Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        order.isDriverAssigned ? Icons.two_wheeler_rounded : Icons.hourglass_top_rounded,
                        size: 18,
                        color: order.isDriverAssigned ? const Color(0xFF0284C7) : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.isDriverAssigned
                              ? 'Assigned Rider: ${order.riderName} (${order.riderVehicle})'
                              : 'Waiting for a nearby rider to accept delivery...',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: order.isDriverAssigned ? const Color(0xFF0F172A) : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Kitchen Action Buttons
                if (isNew) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        orderProvider.updateOrderStatus(order.orderId, OrderStatus.prepped);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Order ${order.orderId} accepted! Chefs started cooking.'),
                            backgroundColor: Colors.orange.shade800,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.soup_kitchen, size: 18),
                      label: const Text('Accept & Start Cooking 🍳', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ] else if (isPrepping) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Food for ${order.orderId} marked READY! Rider notified for pickup.'),
                            backgroundColor: AppTheme.primaryGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: const Text('Food Ready for Rider Pickup 🛵', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ] else if (isPickedUp) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Rider is en route to customer destination 🛵',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryGreen),
                      ),
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
  // TAB 2: RESTAURANT EARNINGS & FINANCE WALLET
  // -------------------------------------------------------------
  Widget _buildRestaurantFinanceTab(List<OrderModel> deliveredOrders) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Wallet Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF831843), Color(0xFF9D174D)],
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
                    Text('RESTAURANT SETTLEMENT WALLET', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    Icon(Icons.verified, color: Colors.white, size: 18),
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
                            const Text('Gross Revenue Today', style: TextStyle(color: Colors.white70, fontSize: 10)),
                            Text('Rs. ${_todaySales.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
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
                            const Text('Dispatched Orders', style: TextStyle(color: Colors.white70, fontSize: 10)),
                            Text('$_completedOrdersToday Orders', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
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
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF831843),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _showRestaurantPayoutDialog,
                    icon: const Icon(Icons.account_balance_rounded, size: 18),
                    label: const Text('Request Payout to Bank Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),
          const Text('Daily Financial Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),

          _buildFinanceRow('Total Food Sales', 'Rs. ${_todaySales.toStringAsFixed(0)}', const Color(0xFF0284C7), Icons.point_of_sale_rounded),
          const SizedBox(height: 10),
          _buildFinanceRow('Bonchi Commission (10%)', '- Rs. ${(_todaySales * 0.1).toStringAsFixed(0)}', Colors.redAccent, Icons.percent_rounded),
          const SizedBox(height: 10),
          _buildFinanceRow('Net Payable to Restaurant', 'Rs. ${_walletBalance.toStringAsFixed(0)}', AppTheme.primaryGreen, Icons.savings_rounded),
        ],
      ),
    );
  }

  Widget _buildFinanceRow(String title, String amount, Color color, IconData icon) {
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
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          Text(amount, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color)),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 3: MENU INVENTORY & STOCK
  // -------------------------------------------------------------
  Widget _buildMenuStockTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Live Kitchen Stock Toggle',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Toggle items Out of Stock when ingredients run out to stop customer orders instantly.',
          style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 14),
        ..._stockStatus.keys.map((item) {
          final isAvailable = _stockStatus[item] ?? true;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(
                        isAvailable ? 'In Stock • Ready to order' : 'Out of Stock • Hidden from menu',
                        style: TextStyle(fontSize: 12, color: isAvailable ? AppTheme.primaryGreen : Colors.redAccent),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isAvailable,
                  activeColor: AppTheme.primaryGreen,
                  onChanged: (val) {
                    setState(() => _stockStatus[item] = val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$item marked as ${val ? 'Available' : 'Sold Out'}'),
                        backgroundColor: val ? AppTheme.primaryGreen : Colors.grey.shade800,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 4: HOTEL PROFILE & OPERATIONS
  // -------------------------------------------------------------
  Widget _buildHotelInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.orange.withValues(alpha: 0.15),
                  child: const Icon(Icons.storefront_rounded, size: 44, color: Colors.orange),
                ),
                const SizedBox(height: 12),
                Text(_restaurantName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 4),
                const Text('Verified Bonchi Partner • 4.8 Rating (520+ Reviews)', style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                _buildHotelInfoRow('Kitchen Address', _restaurantAddress, Icons.location_on_rounded),
                const SizedBox(height: 12),
                _buildHotelInfoRow('Kitchen Contact', _restaurantPhone, Icons.phone_rounded),
                const SizedBox(height: 12),
                _buildHotelInfoRow('Average Food Prep Time', '12 - 18 Minutes', Icons.timer_rounded),
                const SizedBox(height: 12),
                _buildHotelInfoRow('Settlement Bank Account', 'Hatton National Bank • Acc 0048 •••• 1192', Icons.account_balance_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelInfoRow(String title, String value, IconData icon) {
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

  void _showRestaurantPayoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Bank Payout Request', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confirm transfer of your available restaurant earnings:',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
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
                      Text('Hatton National Bank (HNB)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Acc: 0048 •••• 1192 • Pilawaos Ltd.', style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Amount: Rs. ${_walletBalance.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryGreen),
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
                  content: Text('Payout request processed! Funds dispatched to HNB account.'),
                  backgroundColor: AppTheme.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Confirm Transfer'),
          ),
        ],
      ),
    );
  }
}
