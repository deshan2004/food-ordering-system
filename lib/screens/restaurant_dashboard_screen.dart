import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../models/chat_message.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import 'order_chat_screen.dart';

class RestaurantDashboardScreen extends StatefulWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  State<RestaurantDashboardScreen> createState() => _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen> {
  int _currentIndex = 0; // 0: Live Orders, 1: Sales & Wallet, 2: Menu Stock, 3: Hotel Profile
  bool _isKitchenOpen = true;

  // Restaurant State
  final String _restaurantName = 'Pilawaos Grand Hotel';
  final String _restaurantAddress = 'No 142, Galle Road, Colombo 03';
  final String _restaurantPhone = '+94 11 257 8899';
  final double _todaySales = 42800.0;
  double _walletBalance = 38520.0; // 90% net after platform fee
  final int _completedOrdersToday = 14;

  final List<Map<String, dynamic>> _menuStockItems = [
    {
      'name': 'Bonchi Special Seafood Kottu',
      'category': 'Chef Signature',
      'price': 2450.0,
      'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80',
      'inStock': true,
    },
    {
      'name': 'Chicken Cheese Kottu',
      'category': 'Kottu Mania',
      'price': 2100.0,
      'image': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80',
      'inStock': true,
    },
    {
      'name': 'Sri Lankan Lamprais Special',
      'category': 'Rice & Curry',
      'price': 2650.0,
      'image': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=600&q=80',
      'inStock': true,
    },
    {
      'name': 'Crispy Pol Roti with Lunu Miris',
      'category': 'Village Bites',
      'price': 850.0,
      'image': 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?auto=format&fit=crop&w=600&q=80',
      'inStock': true,
    },
    {
      'name': 'Faluda Royal Deluxe',
      'category': 'Beverages',
      'price': 950.0,
      'image': 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?auto=format&fit=crop&w=600&q=80',
      'inStock': true,
    },
  ];

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
                          color: Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          'KITCHEN',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.orange,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$_restaurantName • Col 03',
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
      body: _buildCurrentTabBody(orderProvider, activeOrders, deliveredOrders),
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
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.white,
            selectedItemColor: Colors.orange.shade700,
            unselectedItemColor: AppTheme.textSecondary,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: activeOrders.isNotEmpty,
                  label: Text('${activeOrders.length}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: Colors.orange.shade700,
                  child: const Icon(Icons.soup_kitchen_outlined, size: 22),
                ),
                activeIcon: Badge(
                  isLabelVisible: activeOrders.isNotEmpty,
                  label: Text('${activeOrders.length}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: Colors.orange.shade700,
                  child: Icon(Icons.soup_kitchen_rounded, color: Colors.orange.shade700, size: 22),
                ),
                label: 'Kitchen',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_outlined, size: 22),
                activeIcon: Icon(Icons.account_balance_wallet_rounded, color: Colors.orange, size: 22),
                label: 'Sales',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu_outlined, size: 22),
                activeIcon: Icon(Icons.restaurant_menu_rounded, color: Colors.orange, size: 22),
                label: 'Menu Stock',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.storefront_outlined, size: 22),
                activeIcon: Icon(Icons.storefront_rounded, color: Colors.orange, size: 22),
                label: 'Hotel Info',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTabBody(
    OrderProvider orderProvider,
    List<OrderModel> activeOrders,
    List<OrderModel> deliveredOrders,
  ) {
    switch (_currentIndex) {
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Kitchen Status Card (Modern Obsidian Card)
          _buildKitchenStatusBanner(),

          const SizedBox(height: 14),

          // 2. Quick Stat Cards (Like User Profile)
          Row(
            children: [
              _buildQuickStatCard('Orders Today', '$_completedOrdersToday Done', Icons.receipt_long_rounded, const Color(0xFF0284C7)),
              const SizedBox(width: 10),
              _buildQuickStatCard('Cooking Now', '${activeOrders.length} Active', Icons.soup_kitchen_rounded, Colors.orange.shade700),
              const SizedBox(width: 10),
              _buildQuickStatCard('Gross Sales', 'Rs. 42.8k', Icons.attach_money_rounded, AppTheme.primaryGreen),
            ],
          ),

          const SizedBox(height: 20),

          // Section Heading
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Incoming Live Orders',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -0.3),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${activeOrders.length} In Queue',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (activeOrders.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
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
                      'No pending food orders right now. Orders placed by customers in Colombo will ring here instantly.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),
            )
          else
            ...activeOrders.map((order) => _buildKitchenOrderCard(orderProvider, order)),

          const SizedBox(height: 90), // Bottom clearance for floating bar
        ],
      ),
    );
  }

  Widget _buildKitchenStatusBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _isKitchenOpen ? const Color(0xFF0F172A) : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
              color: _isKitchenOpen ? const Color(0xFF22C55E) : Colors.amber,
              boxShadow: [
                BoxShadow(
                  color: (_isKitchenOpen ? const Color(0xFF22C55E) : Colors.amber).withValues(alpha: 0.6),
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
                  _isKitchenOpen ? 'Kitchen: OPEN & COOKING' : 'Kitchen: BUSY / PAUSED',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _isKitchenOpen ? 'Receiving online food orders' : 'New orders temporarily paused',
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
              value: _isKitchenOpen,
              activeColor: const Color(0xFF22C55E),
              onChanged: (val) {
                setState(() => _isKitchenOpen = val);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(val ? 'Kitchen is Open for orders!' : 'Kitchen paused.'),
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3)),
          ],
          border: Border.all(color: Colors.white.withValues(alpha: 0.95), width: 1.2),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
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
        ? 'NEW ORDER'
        : isPrepping
            ? 'COOKING'
            : 'PICKED UP';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
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
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.primaryGreen),
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
                    const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${order.customerName} • ${order.deliveryAddress}',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderChatScreen(
                              order: order,
                              initialTab: ChatParticipantType.restaurant,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 12, color: Colors.orange.shade800),
                            const SizedBox(width: 4),
                            Text('Chat', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Food Items Ticket (POS Receipt Style)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.restaurant, size: 14, color: Color(0xFF92400E)),
                          SizedBox(width: 6),
                          Text('KITCHEN PREP TICKET', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF92400E), letterSpacing: 0.6)),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      item.foodItem.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                                if (item.selectedSpiceLevel != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '🌶️ ${item.selectedSpiceLevel!.name}',
                                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.red.shade800),
                                    ),
                                  ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Assigned Driver Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
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
                            fontSize: 11.5,
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                      label: const Text('Accept & Start Cooking 🍳', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                      label: const Text('Food Ready for Rider Pickup 🛵', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppTheme.primaryGreen),
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
  // TAB 2: SALES & FINANCE WALLET
  // -------------------------------------------------------------
  Widget _buildRestaurantFinanceTab(List<OrderModel> deliveredOrders) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Wallet Card (Luxury Maroon/Navy Gradient)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF831843), Color(0xFF9D174D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF831843).withValues(alpha: 0.3),
                  blurRadius: 18,
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
                    Text('RESTAURANT SETTLEMENT WALLET', style: TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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
                          color: Colors.white.withValues(alpha: 0.12),
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
                          color: Colors.white.withValues(alpha: 0.12),
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
                    label: const Text('Request Payout to Bank Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),
          const Text('Daily Financial Breakdown', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),

          _buildFinanceRow('Total Food Sales', 'Rs. ${_todaySales.toStringAsFixed(0)}', const Color(0xFF0284C7), Icons.point_of_sale_rounded),
          const SizedBox(height: 10),
          _buildFinanceRow('Bonchi Commission (10%)', '- Rs. ${(_todaySales * 0.1).toStringAsFixed(0)}', Colors.redAccent, Icons.percent_rounded),
          const SizedBox(height: 10),
          _buildFinanceRow('Net Payable to Restaurant', 'Rs. ${_walletBalance.toStringAsFixed(0)}', AppTheme.primaryGreen, Icons.savings_rounded),

          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _buildFinanceRow(String title, String amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        const Text(
          'Live Kitchen Stock Toggle',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Toggle items Out of Stock when ingredients run out to stop customer orders instantly.',
          style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 14),
        ..._menuStockItems.map((item) {
          final isAvailable = (item['inStock'] as bool?) ?? true;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isAvailable
                    ? Colors.white.withValues(alpha: 0.95)
                    : Colors.red.withValues(alpha: 0.3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Food Photo Thumbnail with Glass Overlay
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        Image.network(
                          item['image'] as String,
                          width: 68,
                          height: 68,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 68,
                            height: 68,
                            color: Colors.orange.shade50,
                            child: const Icon(Icons.fastfood_rounded, color: Colors.orange),
                          ),
                        ),
                        if (!isAvailable)
                          Container(
                            width: 68,
                            height: 68,
                            color: Colors.black.withValues(alpha: 0.58),
                            alignment: Alignment.center,
                            child: const Text(
                              'SOLD OUT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['category'] as String,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              'Rs. ${(item['price'] as double).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 3.5,
                              height: 3.5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isAvailable ? 'In Stock' : 'Out of Stock',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isAvailable ? AppTheme.primaryGreen : Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Transform.scale(
                    scale: 0.82,
                    child: Switch(
                      value: isAvailable,
                      activeColor: AppTheme.primaryGreen,
                      onChanged: (val) {
                        setState(() => item['inStock'] = val);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item['name']} marked as ${val ? 'In Stock' : 'Sold Out'}'),
                            backgroundColor: val ? AppTheme.primaryGreen : Colors.grey.shade800,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 90),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 4: HOTEL PROFILE & OPERATIONS
  // -------------------------------------------------------------
  Widget _buildHotelInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
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
          const SizedBox(height: 90),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Bank Payout Request', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
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
