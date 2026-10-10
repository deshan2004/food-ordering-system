import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/loyalty_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_box.dart';

class LoyaltyRewardsScreen extends StatefulWidget {
  const LoyaltyRewardsScreen({super.key});

  @override
  State<LoyaltyRewardsScreen> createState() => _LoyaltyRewardsScreenState();
}

class _LoyaltyRewardsScreenState extends State<LoyaltyRewardsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _coinRotateController;

  @override
  void initState() {
    super.initState();
    _coinRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _coinRotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loyalty = Provider.of<LoyaltyProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: settings.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        title: Text(
          settings.isSinhala ? 'Bonchi Rewards & Loyalty 🪙' : 'Bonchi Rewards & VIP 🪙',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showPerksInfoModal(context),
            tooltip: 'View Tier Perks',
          ),
        ],
      ),
      body: GlassAmbientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // VIP Metallic Membership Card
              _buildVipMembershipCard(context, loyalty, user?.name ?? 'Bonchi Foodie'),

              const SizedBox(height: 20),

              // Daily Streak Mystery Box
              _buildDailyCheckInCard(context, loyalty),

              const SizedBox(height: 22),

              // Tier Perks Comparison Carousel / Cards
              Text(
                settings.isSinhala ? 'ඔබගේ VIP වරප්‍රසාද (Tier Perks)' : 'VIP Tier Privileges',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildTierPerksList(context, loyalty.currentTier),

              const SizedBox(height: 24),

              // Coin Activity / History Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    settings.isSinhala ? 'කාසි ඉතිහාසය (Coin History)' : 'Coin Activity & History',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${loyalty.transactions.length} records',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Transactions List
              if (loyalty.transactions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.glassDecoration(opacity: 0.88, borderRadius: 16),
                  alignment: Alignment.center,
                  child: const Text('No coin activity yet. Place an order to earn coins!'),
                )
              else
                ...loyalty.transactions.map((tx) => _buildTransactionTile(tx)),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVipMembershipCard(BuildContext context, LoyaltyProvider loyalty, String userName) {
    final tier = loyalty.currentTier;

    // Distinct VIP metallic gradients by tier
    List<Color> gradientColors;
    Color accentBorder;
    Color badgeColor;

    switch (tier) {
      case LoyaltyTier.platinum:
        gradientColors = [
          const Color(0xFF1E1B4B),
          const Color(0xFF4338CA),
          const Color(0xFF6D28D9),
        ];
        accentBorder = const Color(0xFFC084FC);
        badgeColor = const Color(0xFFE9D5FF);
        break;
      case LoyaltyTier.gold:
        gradientColors = [
          const Color(0xFF78350F),
          const Color(0xFFB45309),
          const Color(0xFFD97706),
        ];
        accentBorder = const Color(0xFFFDE68A);
        badgeColor = const Color(0xFFFEF3C7);
        break;
      case LoyaltyTier.silver:
        gradientColors = [
          const Color(0xFF1E293B),
          const Color(0xFF334155),
          const Color(0xFF475569),
        ];
        accentBorder = const Color(0xFFCBD5E1);
        badgeColor = const Color(0xFFF1F5F9);
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: accentBorder.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Top Row: Brand & Tier Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/bonchi_logo.png',
                      width: 28,
                      height: 28,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'BONCHI VIP CLUB',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tier.badgeEmoji, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      tier.displayName.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Member Name & ID
          Text(
            userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'MEMBER #BC-${userName.toUpperCase().replaceAll(' ', '').substring(0, math.min(4, userName.length))}-2026',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),

          const SizedBox(height: 18),

          // Coin Balance Block
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AVAILABLE COIN BALANCE',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${loyalty.coinsBalance}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '🪙 Coins',
                        style: TextStyle(
                          color: Color(0xFFFDE68A),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: Text(
                  '= Rs. ${loyalty.coinsBalance}.00',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Tier Progression Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: loyalty.tierProgress,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFDE68A)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${loyalty.lifetimeCoinsEarned} Lifetime Coins',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                tier == LoyaltyTier.platinum
                    ? 'Max VIP Tier Reached 💎'
                    : '${loyalty.coinsToNextTier} coins to next tier',
                style: const TextStyle(
                  color: Color(0xFFFDE68A),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCheckInCard(BuildContext context, LoyaltyProvider loyalty) {
    final bool canClaim = loyalty.canClaimDailyBonus;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration(
        opacity: 0.92,
        borderRadius: 20,
        blurRadius: 10,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: canClaim ? const Color(0xFFFEF3C7) : const Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
            child: Text(canClaim ? '🎁' : '✅', style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Flexible(
                      child: Text(
                        'Daily Streak Check-in',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '+40 Coins',
                        style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  canClaim
                      ? 'Tap claim to collect today’s 40 bonus coins!'
                      : 'You already collected today’s bonus. Return tomorrow!',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canClaim ? AppTheme.primaryGreen : Colors.grey.shade300,
              foregroundColor: canClaim ? Colors.white : Colors.grey.shade600,
              elevation: canClaim ? 2 : 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: canClaim
                ? () {
                    final bonus = loyalty.claimDailyBonus();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Text('🎉', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Claimed +$bonus Bonchi Coins! Your new balance is ${loyalty.coinsBalance} 🪙',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppTheme.primaryGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                : null,
            child: Text(canClaim ? 'Claim' : 'Claimed', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildTierPerksList(BuildContext context, LoyaltyTier currentTier) {
    final perks = currentTier.tierPerks;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration(
        opacity: 0.90,
        borderRadius: 20,
        blurRadius: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Your Active Perks (${currentTier.displayName})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppTheme.primaryGreen),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${currentTier.earnMultiplier}x Multiplier',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFD97706)),
              ),
            ],
          ),
          const Divider(height: 20),
          ...perks.map(
            (perk) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      perk,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, height: 1.3),
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

  Widget _buildTransactionTile(CoinTransaction tx) {
    final isCredit = tx.isCredit;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.glassDecoration(
        opacity: 0.90,
        borderRadius: 16,
        blurRadius: 8,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCredit ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.add_circle_outline_rounded : Icons.remove_circle_outline_rounded,
              color: isCredit ? AppTheme.primaryGreen : AppTheme.accentRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  tx.description,
                  style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : ''}${tx.coins} 🪙',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14.5,
                  color: isCredit ? AppTheme.primaryGreen : AppTheme.accentRed,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${tx.timestamp.day}/${tx.timestamp.month}/${tx.timestamp.year}',
                style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPerksInfoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
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
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Bonchi VIP Membership Tiers 👑', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Climb the tiers as you order more delicious food with Bonchi!', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5)),
            const SizedBox(height: 16),
            _buildTierExplanationTile('Silver Foodie 🥈', '0 - 499 coins', '1.0x earn rate • Weekly promo codes'),
            const SizedBox(height: 10),
            _buildTierExplanationTile('Gold Connoisseur 🥇', '500 - 1,499 coins', '1.5x earn rate • Priority kitchen prep • Free delivery over Rs. 2,500'),
            const SizedBox(height: 10),
            _buildTierExplanationTile('Platinum VIP Gourmet 💎', '1,500+ coins', '2.0x earn rate • Unlimited Free Delivery • VIP hotline • Chef gifts'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Got It!', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierExplanationTile(String title, String threshold, String perks) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              Text(threshold, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
            ],
          ),
          const SizedBox(height: 4),
          Text(perks, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
