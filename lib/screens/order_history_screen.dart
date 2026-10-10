import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import 'order_tracking_screen.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _selectedFilter = 'All';

  String _formatLkr(double val) {
    return 'LKR ${val.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute $period';

    if (isToday) {
      return 'Today at $timeStr';
    } else {
      return '${dt.day}/${dt.month}/${dt.year} at $timeStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final allOrders = orderProvider.orders;

    final filteredOrders = allOrders.where((o) {
      if (_selectedFilter == 'Active') return o.status != OrderStatus.delivered;
      if (_selectedFilter == 'Completed') return o.status == OrderStatus.delivered;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('My Orders & Re-Order', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                _buildFilterChip('All', allOrders.length),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Active',
                  allOrders.where((o) => o.status != OrderStatus.delivered).length,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Completed',
                  allOrders.where((o) => o.status == OrderStatus.delivered).length,
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: filteredOrders.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _buildOrderCard(context, order, cart);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String title, int count) {
    final isSelected = _selectedFilter == title;
    return ChoiceChip(
      label: Text('$title ($count)'),
      selected: isSelected,
      selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.bold,
        color: isSelected ? AppTheme.primaryGreen : AppTheme.textPrimary,
      ),
      onSelected: (val) {
        if (val) setState(() => _selectedFilter = title);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_rounded, size: 64, color: Color(0xFF3B82F6)),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Orders Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Once you place your first order with Bonchi, you can track it live, view receipts, and re-order in just one tap right here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order, CartProvider cart) {
    final isDelivered = order.status == OrderStatus.delivered;
    final isScheduled = order.deliveryTimeOption != 'ASAP (20-25 min)';

    return Container(
      decoration: AppTheme.glassDecoration(
        opacity: 0.94,
        borderRadius: 20,
        blurRadius: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDelivered ? const Color(0xFFF9FAFB) : const Color(0xFFECFDF5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              order.restaurantName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            order.orderId,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(order.orderTime),
                        style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDelivered ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isDelivered ? 'DELIVERED' : (order.status == OrderStatus.onTheWay ? 'ON THE WAY' : 'PREPARING'),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: isDelivered ? const Color(0xFF166534) : const Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Order Items Preview
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isScheduled) ...[
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 14, color: AppTheme.primaryGreen),
                      const SizedBox(width: 6),
                      Text(
                        'Scheduled: ${order.deliveryTimeOption}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                // Items list
                ...order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${item.quantity}x',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${item.foodItem.name} ${item.selectedSpiceLevel != null ? "(${item.selectedSpiceLevel!.name})" : ""}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatLkr(item.totalPriceLkr),
                          style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Grand Total & Savings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Paid', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                        Text(
                          _formatLkr(order.grandTotalLkr),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                        ),
                      ],
                    ),
                    if (order.discountLkr > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Saved ${_formatLkr(order.discountLkr)} 🎟️',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 14),

                // Action Buttons: 1-Tap Re-Order & Receipt
                Row(
                  children: [
                    // 1-Tap Re-Order Button
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          // 1-Tap Re-Order
                          cart.reorderItems(order.items);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('⚡ Re-ordered ${order.items.length} items from ${order.restaurantName}!'),
                              backgroundColor: AppTheme.primaryGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              action: SnackBarAction(
                                label: 'Checkout',
                                textColor: Colors.white,
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
                                },
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.replay_rounded, size: 18),
                        label: const Text(
                          '1-Tap Re-Order ⚡',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Details / Receipt Button
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textPrimary,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _showReceiptSheet(context, order),
                        child: const Text('Receipt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                      ),
                    ),

                    if (!isDelivered) ...[
                      const SizedBox(width: 8),
                      // Live Track Button
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => OrderTrackingScreen(order: order)),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.navigation_rounded, color: AppTheme.primaryOrange, size: 18),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReceiptSheet(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order Receipt', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(order.orderId, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(height: 20),
            Text('Restaurant: ${order.restaurantName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
            Text('Delivery to: ${order.deliveryAddress}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 12),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.quantity}x ${item.foodItem.name}', style: const TextStyle(fontSize: 13)),
                      Text(_formatLkr(item.totalPriceLkr), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                )),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                Text(_formatLkr(order.subtotalLkr), style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Delivery Fee', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                Text(order.deliveryFeeLkr == 0 ? 'FREE' : _formatLkr(order.deliveryFeeLkr), style: const TextStyle(fontSize: 13)),
              ],
            ),
            if (order.discountLkr > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Discount Promo', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text('- ${_formatLkr(order.discountLkr)}', style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Paid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(_formatLkr(order.grandTotalLkr), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.primaryGreen)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  final cart = Provider.of<CartProvider>(context, listen: false);
                  cart.reorderItems(order.items);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                },
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Re-Order These Items Now ⚡', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
