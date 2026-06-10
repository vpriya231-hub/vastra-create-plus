import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v_astra_create/providers/user_provider.dart';
import 'package:v_astra_create/services/admob_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Dashboard page showing user profile, credits, and app generation
class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load ads for free tier users
    _loadAdsForFreeTier();
  }

  void _loadAdsForFreeTier() {
    final userProvider = context.read<UserProvider>();
    if (userProvider.isFreeTier) {
      final admobService = context.read<AdMobService>();
      admobService.loadBannerAd(showForFreeTierOnly: true);
      admobService.loadInterstitialAd(showForFreeTierOnly: true);
      admobService.loadRewardedAd(showForFreeTierOnly: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('V Astra Create'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${userProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => userProvider.refreshUserData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final userData = userProvider.userData;
          if (userData == null) {
            return const Center(child: Text('No user data'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tier Card
                  _buildTierCard(context, userData),
                  const SizedBox(height: 24),
                  // Stats
                  _buildStatsRow(context, userData),
                  const SizedBox(height: 24),
                  // Action Buttons
                  _buildActionButtons(context, userProvider),
                  const SizedBox(height: 24),
                  // Upgrade Card (if free tier)
                  if (userProvider.isFreeTier) _buildUpgradeCard(context),
                  const SizedBox(height: 24),
                  // Banner Ad (if free tier)
                  if (userProvider.isFreeTier) _buildBannerAd(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTierCard(BuildContext context, UserData userData) {
    final tierColors = {
      'free': Colors.grey,
      'plus': Colors.blue,
      'pro': Colors.purple,
      'ultra': Colors.orange,
    };

    final tierNames = {
      'free': 'Free Plan',
      'plus': 'Plus Plan',
      'pro': 'Pro Plan',
      'ultra': 'Ultra Plan',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tierColors[userData.tier]!.withOpacity(0.8),
            tierColors[userData.tier]!.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: tierColors[userData.tier]!.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tierNames[userData.tier] ?? 'Unknown Plan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Credits Available',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${userData.remainingCredits} / ${userData.maxPrompts}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: userData.remainingCredits / userData.maxPrompts,
                          strokeWidth: 4,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                      Text(
                        '${((userData.remainingCredits / userData.maxPrompts) * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, UserData userData) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.auto_awesome,
            label: 'Prompts Used',
            value: '${userData.totalPrompts}',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.trending_up,
            label: 'Max Prompts',
            value: '${userData.maxPrompts}',
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[400],
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, UserProvider userProvider) {
    final isDisabled = !userProvider.hasCredits;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: isDisabled ? null : () => _handleGenerateApp(context, userProvider),
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Generate New App'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: isDisabled ? Colors.grey : Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
        ),
        if (isDisabled)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'No credits available. Upgrade your plan.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red[300],
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pushNamed('/my-apps'),
          icon: const Icon(Icons.apps),
          label: const Text('My Apps'),
        ),
      ],
    );
  }

  Widget _buildUpgradeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber[700]!.withOpacity(0.8),
            Colors.amber[600]!.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Upgrade to Unlock More',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Get more credits, remove ads, and unlock premium features.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/subscription'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.amber[700],
              ),
              child: const Text('View Plans'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerAd(BuildContext context) {
    final admobService = context.read<AdMobService>();
    final bannerAd = admobService.bannerAd;

    if (bannerAd == null) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'Banner Ad',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[400],
                ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 50,
      child: AdWidget(ad: bannerAd),
    );
  }

  void _handleGenerateApp(BuildContext context, UserProvider userProvider) {
    // Show interstitial ad for free tier
    if (userProvider.isFreeTier) {
      final admobService = context.read<AdMobService>();
      admobService.showInterstitialAd();
    }

    // Navigate to generate page
    Navigator.of(context).pushNamed('/generate');
  }
}
