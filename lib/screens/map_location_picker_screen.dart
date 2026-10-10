import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class MapLocationPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;

  const MapLocationPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
  });

  @override
  State<MapLocationPickerScreen> createState() => _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late LatLng _currentCenter;
  double _currentZoom = 15.5;

  bool _isDragging = false;
  bool _isLoadingGps = false;
  bool _isResolvingAddress = false;

  String _formattedAddress = '';
  String _shortLocationName = '';
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<LocationResult> _searchResults = [];
  bool _isSearching = false;
  Timer? _geocodeDebounce;
  Timer? _searchDebounce;

  late AnimationController _pinAnimController;
  late Animation<double> _pinJumpAnimation;

  @override
  void initState() {
    super.initState();

    final defaultLat = widget.initialLatitude ?? 6.9085;
    final defaultLng = widget.initialLongitude ?? 79.8512;
    _currentCenter = LatLng(defaultLat, defaultLng);
    _formattedAddress = widget.initialAddress ?? 'Detecting location...';
    _shortLocationName = 'Selected Location';

    _pinAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _pinJumpAnimation = Tween<double>(begin: 0.0, end: -12.0).animate(
      CurvedAnimation(parent: _pinAnimController, curve: Curves.easeOutBack),
    );

    // Initial reverse geocoding
    _triggerReverseGeocode(_currentCenter.latitude, _currentCenter.longitude);
  }

  @override
  void dispose() {
    _geocodeDebounce?.cancel();
    _searchDebounce?.cancel();
    _pinAnimController.dispose();
    _detailController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _triggerReverseGeocode(double lat, double lng) {
    _geocodeDebounce?.cancel();
    setState(() {
      _isResolvingAddress = true;
    });

    _geocodeDebounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final result = await LocationService.reverseGeocode(lat, lng);
        if (mounted) {
          setState(() {
            _formattedAddress = result.formattedAddress;
            _shortLocationName = result.shortLocationName;
            _isResolvingAddress = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _formattedAddress = 'Location (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
            _shortLocationName = 'Pinned Location';
            _isResolvingAddress = false;
          });
        }
      }
    });
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      final results = await LocationService.searchPlaces(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  void _selectSearchResult(LocationResult result) {
    final target = LatLng(result.latitude, result.longitude);
    _searchFocusNode.unfocus();
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _currentCenter = target;
      _formattedAddress = result.formattedAddress;
      _shortLocationName = result.shortLocationName;
    });
    _mapController.move(target, 16.0);
  }

  Future<void> _fetchAndCenterLiveGps() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _isLoadingGps = true;
    });

    try {
      final liveLoc = await LocationService.fetchLiveLocation(allowMockFallback: false);
      final target = LatLng(liveLoc.latitude, liveLoc.longitude);

      if (mounted) {
        setState(() {
          _currentCenter = target;
          _formattedAddress = liveLoc.formattedAddress;
          _shortLocationName = liveLoc.shortLocationName;
        });

        _mapController.move(target, 16.5);

        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.gps_fixed, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('Live GPS Located: ${liveLoc.shortLocationName}')),
              ],
            ),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.accentRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingGps = false;
        });
      }
    }
  }

  void _confirmAndApplyLocation() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    String fullAddress = _formattedAddress;
    if (_detailController.text.trim().isNotEmpty) {
      fullAddress = '${_detailController.text.trim()}, $fullAddress';
    }

    final finalResult = LocationResult(
      latitude: _currentCenter.latitude,
      longitude: _currentCenter.longitude,
      formattedAddress: fullAddress,
      shortLocationName: _shortLocationName,
    );

    if (auth.currentUser != null) {
      auth.updateProfile(
        address: fullAddress,
        latitude: _currentCenter.latitude,
        longitude: _currentCenter.longitude,
      );
    }

    Navigator.pop(context, finalResult);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. Interactive OpenStreetMap
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentCenter,
                initialZoom: _currentZoom,
                minZoom: 10.0,
                maxZoom: 18.5,
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture) {
                    if (!_isDragging) {
                      _isDragging = true;
                      _pinAnimController.forward();
                    }
                    _currentCenter = position.center;
                    _currentZoom = position.zoom;
                  }
                },
                onMapEvent: (event) {
                  if (event is MapEventMoveEnd) {
                    if (_isDragging) {
                      _isDragging = false;
                      _pinAnimController.reverse();
                    }
                    _triggerReverseGeocode(_currentCenter.latitude, _currentCenter.longitude);
                  }
                },
                onTap: (tapPosition, point) {
                  _mapController.move(point, _currentZoom);
                  setState(() {
                    _currentCenter = point;
                  });
                  _triggerReverseGeocode(point.latitude, point.longitude);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.bonchi.food_ordering_system',
                ),
              ],
            ),
          ),

          // 2. Fixed Center Marker Pin with Hover & Bounce
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35),
              child: AnimatedBuilder(
                animation: _pinJumpAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _pinJumpAnimation.value),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Label bubble above pin
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Deliver Here',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Custom Marker Icon
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryGreen.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.restaurant, color: Colors.white, size: 22),
                            ),
                          ],
                        ),
                        // Pin Pointer needle
                        CustomPaint(
                          size: const Size(14, 10),
                          painter: _PinNeedlePainter(AppTheme.primaryGreen),
                        ),
                        // Shadow dot on map ground
                        Container(
                          width: 12,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. Top Navigation & Search Bar
          Positioned(
            top: topPadding + 10,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Back Button
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Search Input Box
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Search road, area, or landmark...',
                            hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                            prefixIcon: const Icon(Icons.search, color: AppTheme.primaryGreen, size: 20),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                  )
                                : (_isSearching
                                    ? const Padding(
                                        padding: EdgeInsets.all(14),
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen),
                                        ),
                                      )
                                    : null),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Search Results Dropdown List
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _searchResults[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.location_on_outlined, color: AppTheme.primaryGreen, size: 20),
                          title: Text(
                            item.shortLocationName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          subtitle: Text(
                            item.formattedAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                          ),
                          onTap: () => _selectSearchResult(item),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // 4. Map Action Buttons (GPS & Zoom)
          Positioned(
            right: 16,
            bottom: 230,
            child: Column(
              children: [
                // Live GPS Floating Action Button
                FloatingActionButton.small(
                  heroTag: 'gps_btn',
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryGreen,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  onPressed: _isLoadingGps ? null : _fetchAndCenterLiveGps,
                  child: _isLoadingGps
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen),
                        )
                      : const Icon(Icons.my_location_rounded, size: 22),
                ),
                const SizedBox(height: 10),

                // Zoom In
                FloatingActionButton.small(
                  heroTag: 'zoom_in_btn',
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.textPrimary,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  onPressed: () {
                    setState(() {
                      _currentZoom = (_currentZoom + 1).clamp(10.0, 18.5);
                    });
                    _mapController.move(_currentCenter, _currentZoom);
                  },
                  child: const Icon(Icons.add, size: 22),
                ),
                const SizedBox(height: 6),

                // Zoom Out
                FloatingActionButton.small(
                  heroTag: 'zoom_out_btn',
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.textPrimary,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  onPressed: () {
                    setState(() {
                      _currentZoom = (_currentZoom - 1).clamp(10.0, 18.5);
                    });
                    _mapController.move(_currentCenter, _currentZoom);
                  },
                  child: const Icon(Icons.remove, size: 22),
                ),
              ],
            ),
          ),

          // 5. Bottom Sheet Delivery Address Confirmation Card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag indicator handle
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
                  const SizedBox(height: 14),

                  // Header and live GPS button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _shortLocationName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (_isResolvingAddress) ...[
                                  const SizedBox(width: 8),
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(strokeWidth: 1.8, color: AppTheme.primaryGreen),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _formattedAddress,
                              style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, height: 1.3),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Optional Floor / Apartment Field
                  TextField(
                    controller: _detailController,
                    decoration: InputDecoration(
                      hintText: 'Building name, floor, or landmark (Optional)',
                      hintStyle: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                      prefixIcon: const Icon(Icons.apartment_rounded, color: AppTheme.textSecondary, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirm Delivery Location Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      onPressed: _confirmAndApplyLocation,
                      icon: const Icon(Icons.check_circle_rounded, size: 20),
                      label: const Text(
                        'Set as Delivery Location',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
}

class _PinNeedlePainter extends CustomPainter {
  final Color color;

  _PinNeedlePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
