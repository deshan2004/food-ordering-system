import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';

class OrderTrackingScreen extends StatefulWidget {
  final OrderModel order;

  const OrderTrackingScreen({super.key, required this.order});

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
                            Navigator.popUntil(context, (route) => route.isFirst);
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
