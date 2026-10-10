import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import 'order_tracking_screen.dart';
import 'map_location_picker_screen.dart';
import '../providers/payment_provider.dart';
import '../models/payment_method_model.dart';
import '../widgets/payment_sheets.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPayment = 'Credit Card';
  String? _deliveryAddress;
  double? _deliveryLat;
  double? _deliveryLng;
  String _deliveryTimeOption = 'ASAP (20-25 min)';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        setState(() {
          _deliveryAddress = auth.currentUser!.address;
          _deliveryLat = auth.currentUser!.latitude;
          _deliveryLng = auth.currentUser!.longitude;
        });
      }
    });
  }

  String _formatLkr(double val) {
    return 'LKR ${val.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final currentAddress = _deliveryAddress ?? (auth.currentUser?.address ?? 'No. 45, Galle Road, Colombo 03');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text('No items to checkout'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery Address Card
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Delivery Address', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        onPressed: () async {
                          final result = await Navigator.push<LocationResult>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MapLocationPickerScreen(
                                initialLatitude: _deliveryLat ?? auth.currentUser?.latitude,
                                initialLongitude: _deliveryLng ?? auth.currentUser?.longitude,
                                initialAddress: currentAddress,
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              _deliveryAddress = result.formattedAddress;
                              _deliveryLat = result.latitude;
                              _deliveryLng = result.longitude;
                            });
                          }
                        },
                        icon: const Icon(Icons.map_rounded, size: 16),
                        label: const Text('Choose on Map', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.glassDecoration(
                      opacity: 0.90,
                      borderRadius: 16,
                      blurRadius: 10,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFFECFDF5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Delivery Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 3),
                              Text(currentAddress, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Estimated Delivery Time
                  Text('Estimated Delivery', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildTimeOptionTile('ASAP (20-25 min)', Icons.bolt),
                      const SizedBox(width: 12),
                      _buildTimeOptionTile('Schedule', Icons.calendar_today_outlined),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Payment Method Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Payment Method', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                        onPressed: () => showAddPaymentCardSheet(context),
                        icon: const Icon(Icons.add, size: 16, color: AppTheme.primaryGreen),
                        label: const Text('Add Card', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Consumer<PaymentProvider>(
                    builder: (context, paymentProvider, _) {
                      final methods = paymentProvider.paymentMethods;
                      if (!methods.any((m) => m.title == _selectedPayment)) {
                        _selectedPayment = paymentProvider.defaultMethod?.title ?? (methods.isNotEmpty ? methods.first.title : 'Cash on Delivery');
                      }
                      return Column(
                        children: methods.map((method) {
                          IconData icon;
                          switch (method.type) {
                            case PaymentType.applePay:
                              icon = Icons.apple;
                              break;
                            case PaymentType.cash:
                              icon = Icons.payments_outlined;
                              break;
                            default:
                              icon = Icons.credit_card;
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildPaymentTile(method.title, method.subtitle, icon),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Order Summary Quick View
                  Text('Order Summary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.glassDecoration(
                      opacity: 0.90,
                      borderRadius: 16,
                      blurRadius: 10,
                    ),
                    child: Column(
                      children: [
                        ...cart.items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.quantity}x ${item.foodItem.name} (${item.selectedSpiceLevel?.name ?? "Regular"})',
                                    style: const TextStyle(fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  _formatLkr(item.totalPriceLkr),
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        }),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(
                              _formatLkr(cart.grandTotalLkr),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Place Order Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        final user = auth.currentUser;
                        final orderProvider = Provider.of<OrderProvider>(context, listen: false);
                        final newOrder = orderProvider.placeOrder(
                          items: cart.items,
                          subtotalLkr: cart.subtotalLkr,
                          deliveryFeeLkr: cart.deliveryFeeLkr,
                          discountLkr: cart.discountLkr,
                          grandTotalLkr: cart.grandTotalLkr,
                          deliveryAddress: currentAddress,
                          customerName: user?.name,
                          customerPhone: user?.phone,
                          paymentMethod: _selectedPayment,
                          destinationLatitude: _deliveryLat,
                          destinationLongitude: _deliveryLng,
                        );

                        cart.clearCart();

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => OrderTrackingScreen(order: newOrder)),
                          (route) => route.isFirst,
                        );
                      },
                      child: const Text('Place Order Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTimeOptionTile(String label, IconData icon) {
    final isSelected = _deliveryTimeOption == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _deliveryTimeOption = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFECFDF5) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppTheme.primaryGreen : AppTheme.lightBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentTile(String title, String subtitle, IconData icon) {
    final isSelected = _selectedPayment == title;

    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = title),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFECFDF5).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.white.withValues(alpha: 0.95),
            width: isSelected ? 1.8 : 1.2,
          ),
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
            Icon(icon, size: 24, color: isSelected ? AppTheme.primaryGreen : AppTheme.textPrimary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 22),
          ],
        ),
      ),
    );
  }
}
