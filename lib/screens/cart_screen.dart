import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/coupon_sheet.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback? onExploreTap;

  const CartScreen({super.key, this.onExploreTap});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  String _formatLkr(double val) {
    return 'LKR ${val.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton.icon(
              onPressed: () => cart.clearCart(),
              icon: const Icon(Icons.delete_outline, color: AppTheme.accentRed, size: 18),
              label: const Text('Clear', style: TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.accentRed,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_forever, color: Colors.white, size: 28),
                        ),
                        onDismissed: (_) => cart.removeItem(item.id),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: AppTheme.glassDecoration(
                            opacity: 0.90,
                            borderRadius: 18,
                            blurRadius: 10,
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item.foodItem.imageUrl,
                                  width: 75,
                                  height: 75,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.foodItem.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    if (item.selectedSpiceLevel != null)
                                      Text(
                                        'Spice: ${item.selectedSpiceLevel!.name} ${item.selectedSpiceLevel!.iconEmoji}',
                                        style: const TextStyle(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                                      ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatLkr(item.totalPriceLkr),
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 15),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF3F4F6),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              InkWell(
                                                onTap: () => cart.updateQuantity(item.id, item.quantity - 1),
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  child: Icon(Icons.remove, size: 14),
                                                ),
                                              ),
                                              Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                              InkWell(
                                                onTap: () => cart.updateQuantity(item.id, item.quantity + 1),
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  child: Icon(Icons.add, size: 14),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Summary Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.95), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 18, offset: const Offset(0, -4)),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Have a coupon?',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                            ),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () => showCouponsBottomSheet(context),
                              icon: const Icon(Icons.confirmation_num_outlined, size: 15, color: AppTheme.primaryGreen),
                              label: const Text(
                                'View Coupons 🎟️',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppTheme.primaryGreen),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _promoController,
                                decoration: InputDecoration(
                                  hintText: 'Enter code (e.g. BONCHI50)',
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  filled: true,
                                  fillColor: const Color(0xFFF3F4F6),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              onPressed: () {
                                if (_promoController.text.isNotEmpty) {
                                  cart.applyPromoCode(_promoController.text);
                                }
                              },
                              child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),

                        if (cart.promoCode.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Chip(
                                label: Text('Promo: ${cart.promoCode} (-${_formatLkr(cart.discountLkr)})'),
                                backgroundColor: const Color(0xFFECFDF5),
                                deleteIcon: const Icon(Icons.close, size: 14),
                                onDeleted: () {
                                  cart.removePromoCode();
                                  _promoController.clear();
                                },
                                labelStyle: const TextStyle(color: AppTheme.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 16),

                        _buildPriceRow('Subtotal', _formatLkr(cart.subtotalLkr)),
                        const SizedBox(height: 6),
                        _buildPriceRow('Delivery Fee', cart.deliveryFeeLkr == 0 ? 'FREE' : _formatLkr(cart.deliveryFeeLkr)),
                        if (cart.discountLkr > 0) ...[
                          const SizedBox(height: 6),
                          _buildPriceRow('Discount', '-${_formatLkr(cart.discountLkr)}', isDiscount: true),
                        ],
                        const Divider(height: 20),
                        _buildPriceRow('Total', _formatLkr(cart.grandTotalLkr), isTotal: true),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Proceed to Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 70, color: AppTheme.primaryGreen),
          const SizedBox(height: 16),
          const Text('Your Cart is Empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Add some delicious Kottu or Rice & Curry to start!', style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white),
            onPressed: widget.onExploreTap ?? () => Navigator.pop(context),
            child: const Text('Browse Menu'),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 16 : 13, fontWeight: isTotal ? FontWeight.bold : FontWeight.w500)),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isDiscount
                ? AppTheme.accentRed
                : isTotal
                    ? AppTheme.primaryGreen
                    : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
