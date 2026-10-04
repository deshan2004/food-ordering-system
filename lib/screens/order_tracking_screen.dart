import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final freshOrder = orderProvider.orders.firstWhere(
          (o) => o.orderId == order.orderId,
          orElse: () => order,
        );

        return Scaffold(
          backgroundColor: const Color(0xFFE2E8F0),
          body: Stack(
            children: [
              // Custom Simulated Map Background Overlay
              Positioned.fill(
                child: CustomPaint(
                  painter: _MapBackgroundPainter(),
                ),
              ),

              // Map Top Bar Controls
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 18,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 16),
                          onPressed: () {
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
                        ),
                      ),

                      // Order ID Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              freshOrder.orderId,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.primaryGreen),
                            ),
                          ],
                        ),
                      ),

                      const CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 18,
                        child: Icon(Icons.public, color: AppTheme.textPrimary, size: 20),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Live Tracking Drawer Card
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -6)),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle bar top
                        Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // LIVE TRACKING Header + Distance Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.circle, color: AppTheme.primaryGreen, size: 8),
                                const SizedBox(width: 6),
                                Text(
                                  'LIVE TRACKING 🚚',
                                  style: TextStyle(
                                    color: AppTheme.primaryGreen.withValues(alpha: 0.9),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '2.4 KM AWAY',
                                style: TextStyle(color: AppTheme.primaryGreen, fontSize: 10, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // ETA Title
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${freshOrder.estimatedMinsLeft} mins ',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                            ),
                            const Text(
                              'until Bonchi!',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Estimated Arrival: ${freshOrder.estimatedArrivalTime} (On Time)',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),

                        const SizedBox(height: 20),

                        // Step Timeline Progress Bar
                        _buildStepProgressBar(context, freshOrder),

                        const SizedBox(height: 20),

                        // Rider Info Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.lightBorder),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(freshOrder.riderName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary)),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.star, color: AppTheme.starYellow, size: 12),
                                        Text(freshOrder.riderRating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      freshOrder.riderVehicle,
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),

                              // Call & Message buttons
                              CircleAvatar(
                                radius: 17,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.phone_outlined, color: Colors.grey.shade700, size: 16),
                              ),
                              const SizedBox(width: 8),
                              const CircleAvatar(
                                radius: 17,
                                backgroundColor: AppTheme.primaryGreen,
                                child: Icon(Icons.message_outlined, color: Colors.white, size: 16),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Order Accordion Box
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.lightBorder),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('${freshOrder.items.length}', style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Pilawaos Night Kottu Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppTheme.textPrimary)),
                                    Text(
                                      '${freshOrder.items.first.foodItem.name} (${freshOrder.items.first.selectedSpiceLevel?.name ?? "Regular"})',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'LKR ${freshOrder.grandTotalLkr.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppTheme.textPrimary),
                              ),
                              const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary, size: 18),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Action Buttons Row
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1F2937), // Dark button
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: () {
                                  Navigator.popUntil(context, (route) => route.isFirst);
                                },
                                child: const Text('View Order History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.textPrimary,
                                side: const BorderSide(color: AppTheme.lightBorder),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () {},
                              icon: const Icon(Icons.help_outline, size: 16),
                              label: const Text('Help', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepProgressBar(BuildContext context, OrderModel order) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            FractionallySizedBox(
              widthFactor: order.statusProgress,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStepNode(isDone: true, label: 'Confirmed'),
                _buildStepNode(isDone: order.statusProgress >= 0.66, label: 'Prepped'),
                _buildStepNode(isDone: order.statusProgress >= 0.85, isCurrent: order.status == OrderStatus.onTheWay, label: 'On the Way'),
                _buildStepNode(isDone: order.statusProgress >= 1.0, label: 'Delivered'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepNode({required bool isDone, bool isCurrent = false, required String label}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isCurrent
              ? AppTheme.primaryGreen
              : isDone
                  ? AppTheme.primaryGreen
                  : Colors.grey.shade300,
          child: Icon(
            isCurrent
                ? Icons.two_wheeler
                : isDone
                    ? Icons.check
                    : Icons.circle,
            color: Colors.white,
            size: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: isDone || isCurrent ? FontWeight.bold : FontWeight.w500,
            color: isDone || isCurrent ? AppTheme.textPrimary : AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}

// Custom Painter to render simulated map roads & pins
class _MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFE2E8F0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    // Simulated roads
    final path = Path()
      ..moveTo(0, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.1)
      ..lineTo(size.width, size.height * 0.3);

    final path2 = Path()
      ..moveTo(size.width * 0.3, 0)
      ..lineTo(size.width * 0.5, size.height * 0.5)
      ..lineTo(size.width * 0.1, size.height * 0.8);

    canvas.drawPath(path, roadPaint);
    canvas.drawPath(path2, roadPaint);

    // Green Delivery Route Line
    final routePaint = Paint()
      ..color = AppTheme.primaryGreen
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final routePath = Path()
      ..moveTo(size.width * 0.75, size.height * 0.12)
      ..lineTo(size.width * 0.45, size.height * 0.28)
      ..lineTo(size.width * 0.35, size.height * 0.42);

    canvas.drawPath(routePath, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
