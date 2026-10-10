import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../models/restaurant_model.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/auth_provider.dart';
import '../services/food_service.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import 'food_detail_screen.dart';
import 'restaurant_detail_screen.dart';
import 'login_screen.dart';
import 'map_location_picker_screen.dart';
import 'dart:ui';
import '../widgets/glass_box.dart';
import '../widgets/avatar_image_helper.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigateTab;

  const HomeScreen({super.key, required this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filterMode = 'country'; // 'country' or 'category'
  String _selectedCountry = 'All';
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _apiFoodItems = [];

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    final items = await FoodService.fetchFoodItemsFromApi();
    if (mounted) {
      setState(() {
        _apiFoodItems = items;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favProvider = Provider.of<FavoritesProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    List<FoodItem> allAvailableItems = _apiFoodItems.isNotEmpty ? _apiFoodItems : FoodService.mockFoodItems;
    List<FoodItem> displayedItems = allAvailableItems;
    if (_searchQuery.isNotEmpty) {
      final lower = _searchQuery.toLowerCase();
      displayedItems = allAvailableItems.where((item) {
        return item.name.toLowerCase().contains(lower) ||
            item.sinhalaName.toLowerCase().contains(lower) ||
            item.restaurantName.toLowerCase().contains(lower) ||
            item.country.toLowerCase().contains(lower) ||
            item.description.toLowerCase().contains(lower) ||
            item.category.toLowerCase().contains(lower) ||
            item.menuCategory.toLowerCase().contains(lower);
      }).toList();
    } else {
      if (_filterMode == 'country' && _selectedCountry != 'All') {
        displayedItems = displayedItems.where((item) => item.country.toLowerCase() == _selectedCountry.toLowerCase()).toList();
      } else if (_filterMode == 'category' && _selectedCategory != 'All') {
        displayedItems = displayedItems.where((item) => item.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
      }
    }

    final List<RestaurantModel> displayedRestaurants = (_filterMode == 'country' && _selectedCountry != 'All')
        ? FoodService.getRestaurantsByCountry(_selectedCountry)
        : FoodService.mockRestaurants;
    final List<RestaurantModel> partnerRestaurants = displayedRestaurants.isNotEmpty
        ? displayedRestaurants
        : FoodService.mockRestaurants;

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: GlassAmbientBackground(
        child: SafeArea(
          child: RefreshIndicator(
          color: AppTheme.primaryGreen,
          onRefresh: () async {
            await _loadFoodItems();
          },
          child: CustomScrollView(
          slivers: [
            // Top Bar: Bonchi Logo | Colombo 03 Pill | Bell | Profile
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Bonchi Brand Mascot Logo & Name
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.eco, color: AppTheme.primaryGreen, size: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Bonchi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryGreen,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),

                    Flexible(
                      child: GestureDetector(
                        onTap: () => _showLocationPickerModal(context, authProvider),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.70),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.95), width: 1.2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 16),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        currentUser?.address.contains(',') == true
                                            ? currentUser!.address.split(',').last.trim()
                                            : (currentUser?.address ?? 'Colombo 03'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          color: AppTheme.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textPrimary, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bell & Profile Avatar
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.notifications_none_outlined, size: 22, color: AppTheme.textPrimary),
                            Positioned(
                              top: 0,
                              right: 2,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppTheme.accentAmber,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => widget.onNavigateTab(3),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
                            ),
                            child: CircleAvatar(
                              radius: 15,
                              backgroundImage: getAvatarImageProvider(currentUser?.avatarUrl),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Greeting Section: Kohomada, Name! 👋 + Pts Flame Capsule
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Text Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  currentUser != null
                                      ? 'Kohomada, ${currentUser.name.split(' ').first}!'
                                      : 'Ayubowan, Guest!',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('👋', style: TextStyle(fontSize: 20)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Bada ginida? Let's get you something tasty!",
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFF475569),
                              height: 1.3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Points Flame Pill or Login Pill
                    GestureDetector(
                      onTap: () {
                        if (currentUser == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        } else {
                          widget.onNavigateTab(3);
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEAD5).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.95), width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withValues(alpha: 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_fire_department_rounded, color: Color(0xFFC2410C), size: 20),
                                const SizedBox(width: 6),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentUser != null ? '${currentUser.rewardsPoints}' : 'Log In',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                        color: Color(0xFF431407),
                                        height: 1.0,
                                      ),
                                    ),
                                    Text(
                                      currentUser != null ? 'Pts' : 'Points',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Color(0xFF431407),
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.70),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.95), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFF64748B), size: 22),
                          const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: const InputDecoration(
                            hintText: 'Find kottu, rolls, kade bath...',
                            hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.mic_none_outlined, color: Color(0xFF334155), size: 22),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      // Filter Button with orange dot badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.tune_rounded, color: AppTheme.primaryGreen, size: 18),
                          ),
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: AppTheme.accentAmber,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // Segmented Filter Mode Controller (Unified Frosted Capsule Track)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.95),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _filterMode = 'country';
                                  _selectedCategory = 'All';
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 240),
                                curve: Curves.easeInOutCubic,
                                decoration: BoxDecoration(
                                  gradient: _filterMode == 'country'
                                      ? const LinearGradient(
                                          colors: [Color(0xFF059669), Color(0xFF10B981)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: _filterMode == 'country' ? null : Colors.transparent,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: _filterMode == 'country'
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF059669).withValues(alpha: 0.35),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('🌍', style: TextStyle(fontSize: 15)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'By Country',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.2,
                                        color: _filterMode == 'country'
                                            ? Colors.white
                                            : const Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _filterMode = 'category';
                                  _selectedCountry = 'All';
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 240),
                                curve: Curves.easeInOutCubic,
                                decoration: BoxDecoration(
                                  gradient: _filterMode == 'category'
                                      ? const LinearGradient(
                                          colors: [Color(0xFF059669), Color(0xFF10B981)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: _filterMode == 'category' ? null : Colors.transparent,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: _filterMode == 'category'
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF059669).withValues(alpha: 0.35),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('🍲', style: TextStyle(fontSize: 15)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'By Food Type',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.2,
                                        color: _filterMode == 'category'
                                            ? Colors.white
                                            : const Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Sleek Horizontal Pill Chips (Country Cuisines OR Food Categories)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
                child: _filterMode == 'country'
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: FoodService.countryCuisines.length,
                        itemBuilder: (context, index) {
                          final c = FoodService.countryCuisines[index];
                          final isSelected = _selectedCountry == c['country'];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCountry = c['country']!;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? const LinearGradient(
                                              colors: [Color(0xFF059669), Color(0xFF10B981)],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : null,
                                      color: isSelected
                                          ? null
                                          : Colors.white.withValues(alpha: 0.75),
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF34D399)
                                            : Colors.white.withValues(alpha: 0.95),
                                        width: isSelected ? 1.5 : 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? const Color(0xFF059669).withValues(alpha: 0.30)
                                              : Colors.black.withValues(alpha: 0.03),
                                          blurRadius: isSelected ? 10 : 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.white.withValues(alpha: 0.22)
                                                : const Color(0xFFF1F5F9),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              c['flag']!,
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          c['name']!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                            letterSpacing: -0.2,
                                            color: isSelected ? Colors.white : AppTheme.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: FoodService.categories.length,
                        itemBuilder: (context, index) {
                          final cat = FoodService.categories[index];
                          final isSelected = _selectedCategory == cat['name'];
                          final badge = cat['badge'] as String;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = cat['name'] as String;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? const LinearGradient(
                                              colors: [Color(0xFF059669), Color(0xFF10B981)],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : null,
                                      color: isSelected
                                          ? null
                                          : Colors.white.withValues(alpha: 0.75),
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF34D399)
                                            : Colors.white.withValues(alpha: 0.95),
                                        width: isSelected ? 1.5 : 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? const Color(0xFF059669).withValues(alpha: 0.30)
                                              : Colors.black.withValues(alpha: 0.03),
                                          blurRadius: isSelected ? 10 : 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.white.withValues(alpha: 0.22)
                                                : const Color(0xFFF1F5F9),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              cat['icon'] as String,
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          cat['name'] as String,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                            letterSpacing: -0.2,
                                            color: isSelected ? Colors.white : AppTheme.textPrimary,
                                          ),
                                        ),
                                        if (badge.isNotEmpty) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.white.withValues(alpha: 0.25)
                                                  : (badge.contains('Hot')
                                                      ? AppTheme.accentRed
                                                      : AppTheme.accentAmber),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              badge,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 8.5,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
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
                      ),
              ),
            ),

            // Top Partner Restaurants & Kitchens Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Partner Restaurants',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${partnerRestaurants.length}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.primaryGreen),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Tap to View Menus ➔',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen.withValues(alpha: 0.9)),
                    ),
                  ],
                ),
              ),
            ),

            // Horizontal Restaurants Carousel
            SliverToBoxAdapter(
              child: SizedBox(
                height: 195,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: partnerRestaurants.length,
                  itemBuilder: (context, index) {
                    final rest = partnerRestaurants[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RestaurantDetailScreen(restaurant: rest),
                          ),
                        );
                      },
                      child: Container(
                        width: 225,
                        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.78),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.95), width: 1.4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Cover Photo with Flag Chip & Rating
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                                        child: Image.network(
                                          rest.coverImageUrl,
                                          height: 95,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            height: 95,
                                            color: const Color(0xFFE2E8F0),
                                            child: const Icon(Icons.restaurant, color: Color(0xFF94A3B8), size: 32),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.65),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(rest.flagEmoji, style: const TextStyle(fontSize: 12)),
                                              const SizedBox(width: 4),
                                              Text(
                                                rest.country,
                                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.92),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.star_rounded, color: AppTheme.starYellow, size: 14),
                                              const SizedBox(width: 2),
                                              Text(
                                                '${rest.rating}',
                                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Restaurant Details
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          rest.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          rest.cuisine,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            color: AppTheme.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.schedule, size: 11, color: AppTheme.primaryGreen),
                                                const SizedBox(width: 3),
                                                Text(
                                                  rest.deliveryTime,
                                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDCFCE7),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'Menu ➔',
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w900,
                                                  color: AppTheme.primaryGreen,
                                                ),
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
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 18)),

            // Rainy Day Deals Promo Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9F0A), Color(0xFFFF6B00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: AppTheme.accentAmber.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.thunderstorm_outlined, color: Colors.white, size: 12),
                                  SizedBox(width: 4),
                                  Text(
                                    'MONSOON CRAVING',
                                    style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Rainy Day Deals! 20%\nOff',
                              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, height: 1.15),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'On steaming hot mutton kottu & spicy crab soups',
                              style: TextStyle(color: Colors.white70, fontSize: 10.5),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'CODE: MONSOON20',
                                    style: TextStyle(color: Color(0xFFFF6B00), fontSize: 9.5, fontWeight: FontWeight.w800),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.white24,
                                  child: Icon(Icons.arrow_forward, color: Colors.white, size: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Image preview on right
                      Positioned(
                        right: 12,
                        top: 12,
                        bottom: 12,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=300&q=80',
                            width: 105,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Popular Near You / Filtered Results Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          _filterMode == 'country' && _selectedCountry != 'All'
                              ? '$_selectedCountry Dishes'
                              : (_filterMode == 'category' && _selectedCategory != 'All'
                                  ? _selectedCategory
                                  : 'Popular Near You'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.circle, color: AppTheme.primaryGreen, size: 8),
                      ],
                    ),
                    if (_selectedCountry != 'All' || _selectedCategory != 'All' || _searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCountry = 'All';
                            _selectedCategory = 'All';
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.close, size: 12, color: AppTheme.accentRed),
                              SizedBox(width: 3),
                              Text('Clear Filter', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentRed)),
                            ],
                          ),
                        ),
                      )
                    else
                      Text('(${displayedItems.length} dishes)', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Restaurant & Dishes Vertical Feed or Empty State
            if (displayedItems.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: GlassCard(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.ramen_dining_outlined, size: 54, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 14),
                        Text(
                          _selectedCountry != 'All'
                              ? 'No $_selectedCountry dishes found'
                              : 'No matching foods found',
                          style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Try clearing your search query or selecting a different country / food type.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedCountry = 'All';
                              _selectedCategory = 'All';
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Show All Cuisines & Dishes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = displayedItems[index];
                    final isFav = favProvider.isFavorite(item.id);

                    return Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.95),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                          // Card Header Image with status pill & heart
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                child: Image.network(
                                  item.imageUrl,
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.circle, color: AppTheme.primaryGreen, size: 7),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${item.country} • ${item.deliveryTime}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.textPrimary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: CircleAvatar(
                                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                                  radius: 17,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      color: isFav ? AppTheme.accentRed : AppTheme.textPrimary,
                                      size: 18,
                                    ),
                                    onPressed: () => favProvider.toggleFavorite(item),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 12,
                                left: 12,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.95),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star, color: AppTheme.starYellow, size: 14),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${item.rating}',
                                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.textPrimary),
                                          ),
                                          Text(
                                            ' (${item.reviewCountText})',
                                            style: const TextStyle(fontSize: 10.5, color: AppTheme.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.95),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.delivery_dining, color: AppTheme.primaryGreen, size: 14),
                                          const SizedBox(width: 3),
                                          Text(
                                            'LKR ${item.deliveryFeeLkr.toInt()} Delivery',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.primaryGreen),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Restaurant Info Details
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    final rest = FoodService.getRestaurantById(item.restaurantId);
                                    if (rest != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => RestaurantDetailScreen(restaurant: rest),
                                        ),
                                      );
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.restaurantName,
                                                style: const TextStyle(fontSize: 17.5, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                item.restaurantSubtitle,
                                                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDCFCE7),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.storefront_outlined, size: 14, color: AppTheme.primaryGreen),
                                              SizedBox(width: 4),
                                              Text(
                                                'Menu ➔',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w900,
                                                  color: AppTheme.primaryGreen,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Signature Hit Card Inset
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => FoodDetailScreen(foodItem: item)),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.0),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    item.signatureTag,
                                                    style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 9.5, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFF1F5F9),
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    child: Text(
                                                      item.category,
                                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                item.signatureItemName,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppTheme.textPrimary),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'LKR ${item.signatureItemPriceLkr.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.primaryGreen),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Green + Add Button
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primaryGreen,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          onPressed: () {
                                            final cart = Provider.of<CartProvider>(context, listen: false);
                                            cart.addToCart(foodItem: item);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Added ${item.name} to Cart!'),
                                                backgroundColor: AppTheme.primaryGreen,
                                                duration: const Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.add, size: 16),
                                          label: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
                  childCount: displayedItems.length,
                ),
              ),

            // Live Deliveries Info Footer Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xFFA7F3D0),
                        radius: 20,
                        child: Icon(Icons.two_wheeler, color: AppTheme.primaryGreen, size: 22),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Track fresh deliveries in live time!',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Bonchi riders zip across Colombo in 25 mins or less.',
                              style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    ),
    );
  }

  void _showLocationPickerModal(BuildContext context, AuthProvider auth) {
    final currentUser = auth.currentUser;
    final addressController = TextEditingController(
      text: currentUser?.address ?? 'No. 45, Galle Road, Colombo 03',
    );
    bool isLoadingGps = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.location_on_rounded, color: AppTheme.primaryGreen, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Select Delivery Location',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 1. Choose on Interactive Map Card
              InkWell(
                onTap: () async {
                  Navigator.pop(ctx);
                  final result = await Navigator.push<LocationResult>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MapLocationPickerScreen(
                        initialLatitude: currentUser?.latitude,
                        initialLongitude: currentUser?.longitude,
                        initialAddress: currentUser?.address,
                      ),
                    ),
                  );
                  if (result != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text('Delivery location updated to: ${result.formattedAddress}')),
                          ],
                        ),
                        backgroundColor: AppTheme.primaryGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.35), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.map_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose on Interactive Map',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppTheme.textPrimary),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Pinpoint exact delivery location with map pin',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.primaryGreen),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 2. Live Device GPS Fetch Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryGreen,
                    side: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: isLoadingGps
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          setModalState(() => isLoadingGps = true);
                          try {
                            final location = await LocationService.fetchLiveLocation(allowMockFallback: false);
                            addressController.text = location.formattedAddress;
                            if (auth.currentUser != null) {
                              auth.updateProfile(
                                address: location.formattedAddress,
                                latitude: location.latitude,
                                longitude: location.longitude,
                              );
                            }
                            if (context.mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.gps_fixed, color: Colors.white, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text('Live GPS Location Detected: ${location.formattedAddress}')),
                                    ],
                                  ),
                                  backgroundColor: AppTheme.primaryGreen,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
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
                            if (context.mounted) {
                              setModalState(() => isLoadingGps = false);
                            }
                          }
                        },
                  icon: isLoadingGps
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen),
                        )
                      : const Icon(Icons.my_location_rounded, size: 18),
                  label: Text(
                    isLoadingGps ? 'Locating your live position...' : '📍 Detect My Live GPS Location',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                ),
              ),

              // 3. Manual Address Input Field
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Delivery Address',
                  hintText: 'Enter street address, building, or landmark',
                  prefixIcon: const Icon(Icons.edit_location_alt_outlined, color: AppTheme.primaryGreen),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 18),

              // 4. Confirm Location Action Button
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
                    if (auth.currentUser != null) {
                      auth.updateProfile(address: addressController.text.trim());
                    }
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Delivery location updated to: ${addressController.text.trim()}'),
                        backgroundColor: AppTheme.primaryGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Confirm Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  );
}
}
