import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../models/chat_message.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import 'order_chat_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  final OrderModel order;
  final VoidCallback? onBackToHome;

  const OrderTrackingScreen({super.key, required this.order, this.onBackToHome});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final MapController _mapController = MapController();
  double _currentZoom = 14.8;
  LatLng? _userGpsLocation;

  // Real Street Coordinates in Colombo
  static const LatLng _restaurantLocation = LatLng(6.9085, 79.8512); // Pilawos Kollupitiya
  static const LatLng _riderLocation = LatLng(6.9048, 79.8530);      // Rider en route on Galle Road
  static const LatLng _defaultDestination = LatLng(6.9015, 79.8560); // Flower Road Col 07

  @override
  void initState() {
    super.initState();
    _fetchUserLiveGps();
  }

  Future<void> _fetchUserLiveGps() async {
    try {
      final loc = await LocationService.fetchLiveLocation();
      if (mounted) {
        setState(() {
          _userGpsLocation = LatLng(loc.latitude, loc.longitude);
        });
        _mapController.move(_userGpsLocation!, 15.0);
      }
    } catch (e) {
      debugPrint('Live GPS fetch fallback: $e');
    }
  }

  LatLng get _targetDestination {
    if (widget.order.destinationLatitude != null && widget.order.destinationLongitude != null) {
      return LatLng(widget.order.destinationLatitude!, widget.order.destinationLongitude!);
    }
    return _userGpsLocation ?? _defaultDestination;
  }

  List<LatLng> get _routePoints => [
        _restaurantLocation,
        const LatLng(6.9072, 79.8518),
        _riderLocation,
        const LatLng(6.9032, 79.8542),
        _targetDestination,
      ];

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 0.8).clamp(10.0, 18.0);
      _mapController.move(_riderLocation, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 0.8).clamp(10.0, 18.0);
      _mapController.move(_riderLocation, _currentZoom);
    });
  }

  void _reCenter() {
    _mapController.move(_riderLocation, 15.0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final freshOrder = orderProvider.orders.firstWhere(
          (o) => o.orderId == widget.order.orderId,
          orElse: () => widget.order,
        );

        return Scaffold(
          backgroundColor: const Color(0xFFE2E8F0),
          body: Stack(
            children: [
              // Real OpenStreetMap Layer using flutter_map
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: LatLng(6.9048, 79.8530),
                  initialZoom: 14.8,
                  maxZoom: 18.5,
                  minZoom: 11.0,
                ),
                children: [
                  // OpenStreetMap Tile Layer
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.bonchi.food_ordering_system',
                  ),

                  // Route Polyline (Green Delivery Path)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 5.5,
                        color: AppTheme.primaryGreen,
                        borderColor: Colors.white,
                        borderStrokeWidth: 1.5,
                      ),
                    ],
                  ),

                  // Map Markers Layer
                  MarkerLayer(
                    markers: [
                      // Restaurant Marker (Pilawos)
                      Marker(
                        point: _restaurantLocation,
                        width: 70,
                        height: 70,
                        child: _buildMapPin(
                          icon: Icons.storefront_rounded,
                          color: const Color(0xFFEA580C),
                          label: 'Pilawos',
                        ),
                      ),

                      // Rider Marker (Bonchi Delivery Rider)
                      Marker(
                        point: _riderLocation,
                        width: 75,
                        height: 75,
                        child: _buildRiderMarker(freshOrder.riderName),
                      ),

                      // Customer Destination Pin
                      Marker(
                        point: _targetDestination,
                        width: 70,
                        height: 70,
                        child: _buildMapPin(
                          icon: Icons.location_on_rounded,
                          color: AppTheme.accentRed,
                          label: 'You',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Map Action Controls (Zoom & Re-center floating column on Right)
              Positioned(
                top: 100,
                right: 16,
                child: Column(
                  children: [
                    _buildMapControlButton(
                      icon: Icons.add,
                      onTap: _zoomIn,
                      tooltip: 'Zoom In',
                    ),
                    const SizedBox(height: 8),
                    _buildMapControlButton(
                      icon: Icons.remove,
                      onTap: _zoomOut,
                      tooltip: 'Zoom Out',
                    ),
                    const SizedBox(height: 8),
                    _buildMapControlButton(
                      icon: Icons.my_location_rounded,
                      onTap: _reCenter,
                      tooltip: 'Re-center Rider',
                      iconColor: AppTheme.primaryGreen,
                    ),
                  ],
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
                            if (widget.onBackToHome != null) {
                              widget.onBackToHome!();
                            } else if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Navigator.popUntil(context, (route) => route.isFirst);
                            }
                          },
                        ),
                      ),

                      // Order ID Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: AppTheme.glassDecoration(
                          opacity: 0.92,
                          borderRadius: 20,
                          blurRadius: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.map_outlined, color: AppTheme.primaryGreen, size: 15),
                            const SizedBox(width: 6),
                            Text(
                              '${freshOrder.orderId} • Live Map',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                      ),

                      const CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 18,
                        child: Icon(Icons.share_outlined, color: AppTheme.textPrimary, size: 18),
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
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.95), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -6)),
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
                                  'LIVE STREET TRACKING 🚚',
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

                        // ETA Title or Delivery Success Header
                        if (freshOrder.status == OrderStatus.delivered) ...[
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 16),
                                    SizedBox(width: 5),
                                    Text(
                                      'Order Delivered! 🎉',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.primaryGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            freshOrder.isRated
                                ? 'Completed & Rated ⭐ Thank you for ordering with Bonchi!'
                                : 'Food arrived safely! Please rate the driver & restaurant.',
                            style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ] else ...[
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
                          Text(
                            freshOrder.deliveryTimeOption == 'ASAP (20-25 min)'
                                ? 'Estimated Arrival: ${freshOrder.estimatedArrivalTime} (On Time)'
                                : 'Scheduled Delivery: ${freshOrder.deliveryTimeOption}',
                            style: TextStyle(
                              fontSize: 12,
                              color: freshOrder.deliveryTimeOption == 'ASAP (20-25 min)' ? AppTheme.textSecondary : AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Step Timeline Progress Bar
                        _buildStepProgressBar(context, freshOrder),

                        const SizedBox(height: 20),

                        // Rider Info Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: AppTheme.glassDecoration(
                            opacity: 0.90,
                            borderRadius: 16,
                            blurRadius: 10,
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/images/bonchi_logo.png',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.contain,
                                ),
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
                              InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 20),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text('Calling rider ${freshOrder.riderName} (+94 77 123 4567)... 📞')),
                                        ],
                                      ),
                                      backgroundColor: AppTheme.primaryGreen,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: CircleAvatar(
                                  radius: 17,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.phone_outlined, color: Colors.grey.shade700, size: 16),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OrderChatScreen(
                                        order: freshOrder,
                                        initialTab: ChatParticipantType.rider,
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: const CircleAvatar(
                                  radius: 17,
                                  backgroundColor: AppTheme.primaryGreen,
                                  child: Icon(Icons.message_outlined, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Order Accordion Box
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: AppTheme.glassDecoration(
                            opacity: 0.88,
                            borderRadius: 14,
                            blurRadius: 8,
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
                                      freshOrder.items.isNotEmpty
                                          ? '${freshOrder.items.first.foodItem.name} (${freshOrder.items.first.selectedSpiceLevel?.name ?? "Regular"})'
                                          : 'Sri Lankan Meal Pack',
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

                        // Action Buttons Row (Delivered vs In Transit)
                        if (freshOrder.status == OrderStatus.delivered && !freshOrder.isRated) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 4,
                                shadowColor: AppTheme.primaryGreen.withValues(alpha: 0.4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () {
                                _showRatingModal(context, orderProvider, freshOrder);
                              },
                              icon: const Icon(Icons.star_rounded, size: 20, color: AppTheme.starYellow),
                              label: const Text(
                                'Rate Driver & Restaurant ⭐',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.textSecondary,
                                    side: BorderSide(color: Colors.grey.shade300),
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () {
                                    orderProvider.clearActiveOrder(freshOrder.orderId);
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    } else {
                                      Navigator.popUntil(context, (route) => route.isFirst);
                                    }
                                  },
                                  child: const Text('Dismiss Order', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.textPrimary,
                                    side: const BorderSide(color: AppTheme.lightBorder),
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () {},
                                  icon: const Icon(Icons.help_outline, size: 15),
                                  label: const Text('Help', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                            ],
                          ),
                        ] else if (freshOrder.status == OrderStatus.delivered && freshOrder.isRated) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1F2937),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () {
                                orderProvider.clearActiveOrder(freshOrder.orderId);
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  Navigator.popUntil(context, (route) => route.isFirst);
                                }
                              },
                              icon: const Icon(Icons.home_outlined, size: 18),
                              label: const Text('Order Complete • Back to Home', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                            ),
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1F2937),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  onPressed: () {
                                    if (widget.onBackToHome != null) {
                                      widget.onBackToHome!();
                                    } else if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    } else {
                                      Navigator.popUntil(context, (route) => route.isFirst);
                                    }
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

  void _showRatingModal(BuildContext context, OrderProvider orderProvider, OrderModel order) {
    int currentStep = 1;
    double riderRating = 5.0;
    final Set<String> riderTags = {'On Time ⚡', 'Polite & Friendly 😊'};
    final TextEditingController riderFeedbackController = TextEditingController();

    double restaurantRating = 5.0;
    final Set<String> restaurantTags = {'Super Tasty 😋', 'Hot & Fresh ♨️'};
    final TextEditingController restaurantFeedbackController = TextEditingController();

    final List<String> riderAvailableTags = [
      'On Time ⚡',
      'Polite & Friendly 😊',
      'Careful Handling 🥡',
      'Fast & Safe 🛵',
      'Followed Instructions 📍',
    ];

    final List<String> restaurantAvailableTags = [
      'Super Tasty 😋',
      'Hot & Fresh ♨️',
      'Perfect Spice Level 🌶️',
      'Generous Portion 🍛',
      'Well Packaged 🥡',
      'Value for Money 💰',
    ];

    String getRiderRatingLabel(double rating) {
      if (rating >= 5) return 'Outstanding Delivery! 🌟';
      if (rating >= 4) return 'Good Service 👍';
      if (rating >= 3) return 'Average Experience 😐';
      if (rating >= 2) return 'Could Be Better 😕';
      return 'Poor Service 😞';
    }

    String getRestaurantRatingLabel(double rating) {
      if (rating >= 5) return 'Delicious & Authentic! 😋';
      if (rating >= 4) return 'Very Tasty 👍';
      if (rating >= 3) return 'Average Food 😐';
      if (rating >= 2) return 'Not Satisfied 😕';
      return 'Poor Quality 😞';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.96),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.14),
                          blurRadius: 28,
                          offset: const Offset(0, -8),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Drag bar handle
                          Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Step badge & Points pill
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: currentStep == 1
                                      ? AppTheme.primaryGreen.withValues(alpha: 0.12)
                                      : Colors.orange.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  currentStep == 1 ? 'STEP 1 OF 2 • DRIVER FEEDBACK' : 'STEP 2 OF 2 • RESTAURANT RATING',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: currentStep == 1 ? AppTheme.primaryGreen : Colors.deepOrange,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.amber.shade200),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.stars_rounded, color: Colors.amber, size: 14),
                                    SizedBox(width: 4),
                                    Text('+50 Pts', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.brown)),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // 2-Step Progress Indicator
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: currentStep == 2 ? AppTheme.primaryGreen : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // STEP 1 CONTENT: DRIVER
                          if (currentStep == 1) ...[
                            // Rider header card
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(22),
                                    child: Image.asset(
                                      'assets/images/bonchi_logo.png',
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.riderName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Delivery Partner • ${order.riderVehicle}',
                                          style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),
                            const Text(
                              'How was your delivery experience?',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 6),

                            // Stars Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                final starVal = index + 1.0;
                                final isSelected = starVal <= riderRating;
                                return IconButton(
                                  iconSize: 36,
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  icon: Icon(
                                    isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                                    color: isSelected ? AppTheme.starYellow : Colors.grey.shade300,
                                  ),
                                  onPressed: () {
                                    setModalState(() {
                                      riderRating = starVal;
                                    });
                                  },
                                );
                              }),
                            ),

                            Text(
                              getRiderRatingLabel(riderRating),
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.primaryGreen),
                            ),

                            const SizedBox(height: 12),

                            // Quick Compliments Chips
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Compliments for the Rider:',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: riderAvailableTags.map((tag) {
                                final isChecked = riderTags.contains(tag);
                                return FilterChip(
                                  label: Text(tag),
                                  selected: isChecked,
                                  selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
                                  checkmarkColor: AppTheme.primaryGreen,
                                  labelStyle: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                                    color: isChecked ? AppTheme.primaryGreen : AppTheme.textPrimary,
                                  ),
                                  backgroundColor: Colors.white,
                                  side: BorderSide(
                                    color: isChecked ? AppTheme.primaryGreen : Colors.grey.shade300,
                                  ),
                                  onSelected: (val) {
                                    setModalState(() {
                                      if (val) {
                                        riderTags.add(tag);
                                      } else {
                                        riderTags.remove(tag);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 10),

                            // Comment text field
                            TextField(
                              controller: riderFeedbackController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText: 'Add a personal compliment for ${order.riderName} (optional)...',
                                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppTheme.primaryGreen),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Next Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: () {
                                  setModalState(() {
                                    currentStep = 2;
                                  });
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Next: Rate Restaurant 🍽️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ]

                          // STEP 2 CONTENT: RESTAURANT
                          else ...[
                            // Restaurant header card
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.orange.shade100),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.restaurant_rounded, color: Colors.white, size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.restaurantName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          order.items.isNotEmpty
                                              ? '${order.items.first.foodItem.name} + ${order.items.length - 1} more'
                                              : 'Sri Lankan Meal Order',
                                          style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),
                            const Text(
                              'How was the food quality & taste?',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 6),

                            // Stars Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                final starVal = index + 1.0;
                                final isSelected = starVal <= restaurantRating;
                                return IconButton(
                                  iconSize: 36,
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  icon: Icon(
                                    isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                                    color: isSelected ? AppTheme.starYellow : Colors.grey.shade300,
                                  ),
                                  onPressed: () {
                                    setModalState(() {
                                      restaurantRating = starVal;
                                    });
                                  },
                                );
                              }),
                            ),

                            Text(
                              getRestaurantRatingLabel(restaurantRating),
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.deepOrange),
                            ),

                            const SizedBox(height: 12),

                            // Quick Food Chips
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'What did you like the most?',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: restaurantAvailableTags.map((tag) {
                                final isChecked = restaurantTags.contains(tag);
                                return FilterChip(
                                  label: Text(tag),
                                  selected: isChecked,
                                  selectedColor: Colors.orange.shade50,
                                  checkmarkColor: Colors.deepOrange,
                                  labelStyle: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                                    color: isChecked ? Colors.deepOrange : AppTheme.textPrimary,
                                  ),
                                  backgroundColor: Colors.white,
                                  side: BorderSide(
                                    color: isChecked ? Colors.deepOrange : Colors.grey.shade300,
                                  ),
                                  onSelected: (val) {
                                    setModalState(() {
                                      if (val) {
                                        restaurantTags.add(tag);
                                      } else {
                                        restaurantTags.remove(tag);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 10),

                            // Comment text field
                            TextField(
                              controller: restaurantFeedbackController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText: 'Share feedback with ${order.restaurantName} (optional)...',
                                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.deepOrange),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Back & Submit Buttons
                            Row(
                              children: [
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.textPrimary,
                                    side: BorderSide(color: Colors.grey.shade300),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  onPressed: () {
                                    setModalState(() {
                                      currentStep = 1;
                                    });
                                  },
                                  child: const Row(
                                    children: [
                                      Icon(Icons.arrow_back_rounded, size: 16),
                                      SizedBox(width: 4),
                                      Text('Back', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryGreen,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      elevation: 3,
                                    ),
                                    onPressed: () {
                                      final riderComment = [
                                        ...riderTags,
                                        if (riderFeedbackController.text.trim().isNotEmpty)
                                          riderFeedbackController.text.trim()
                                      ].join(', ');

                                      final restComment = [
                                        ...restaurantTags,
                                        if (restaurantFeedbackController.text.trim().isNotEmpty)
                                          restaurantFeedbackController.text.trim()
                                      ].join(', ');

                                      orderProvider.submitOrderRatings(
                                        orderId: order.orderId,
                                        riderRating: riderRating,
                                        riderFeedback: riderComment,
                                        restaurantRating: restaurantRating,
                                        restaurantFeedback: restComment,
                                      );

                                      // Award +50 rewards points
                                      try {
                                        Provider.of<AuthProvider>(context, listen: false).addRewardPoints(50);
                                      } catch (_) {}

                                      // Clear active order so screen & app session refresh
                                      orderProvider.clearActiveOrder(order.orderId);

                                      Navigator.pop(modalContext);

                                      if (Navigator.canPop(context)) {
                                        Navigator.pop(context);
                                      } else {
                                        Navigator.popUntil(context, (route) => route.isFirst);
                                      }

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: const Color(0xFF1F2937),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          content: const Row(
                                            children: [
                                              Icon(Icons.stars_rounded, color: AppTheme.starYellow, size: 24),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  'Thank you for rating! +50 Bonchi points awarded to your wallet ⭐',
                                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Submit & Finish 🎉',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    Color iconColor = AppTheme.textPrimary,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 20),
        onPressed: onTap,
        tooltip: tooltip,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildMapPin({required IconData icon, required Color color, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4)),
            ],
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildRiderMarker(String riderName) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing background glow
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(color: AppTheme.primaryGreen.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: const Icon(Icons.two_wheeler, color: Colors.white, size: 22),
        ),
      ],
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
