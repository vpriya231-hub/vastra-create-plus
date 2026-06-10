import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v_astra_create/services/billing_service.dart';
import 'package:v_astra_create/providers/user_provider.dart';

/// Subscription management page with Google Play billing
class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool _isLoading = false;
  String? _errorMessage;

  final subscriptionPlans = [
    {
      'tier': 'free',
      'name': 'Free',
      'price': '\$0',
      'period': 'Forever',
      'credits': '5',
      'prompts': '5',
      'apps': '2',
      'features': [
        'AI-powered app generation',
        'Basic support',
        'Ads included',
      ],
      'productId': null,
    },
    {
      'tier': 'plus',
      'name': 'Plus',
      'price': '\$4.99',
      'period': '/month',
      'credits': '25',
      'prompts': '25',
      'apps': '5',
      'features': [
        'All Free features',
        'Ad-free experience',
        'Priority support',
        'Advanced analytics',
      ],
      'productId': BillingService.plusProductId,
      'popular': true,
    },
    {
      'tier': 'pro',
      'name': 'Pro',
      'price': '\$9.99',
      'period': '/month',
      'credits': '60',
      'prompts': '60',
      'apps': '15',
      'features': [
        'All Plus features',
        'Advanced customization',
        'API access',
        'Team collaboration',
      ],
      'productId': BillingService.proProductId,
    },
    {
      'tier': 'ultra',
      'name': 'Ultra',
      'price': '\$19.99',
      'period': '/month',
      'credits': '100',
      'prompts': '100',
      'apps': '20',
      'features': [
        'All Pro features',
        'Unlimited everything',
        'Dedicated support',
        'Custom integrations',
      ],
      'productId': BillingService.ultraProductId,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Choose Your Plan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Unlock more credits and remove ads',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[400],
                    ),
              ),
              const SizedBox(height: 24),
              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[300]),
                  ),
                ),
              if (_errorMessage != null) const SizedBox(height: 16),
              // Plans
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: subscriptionPlans.length,
                itemBuilder: (context, index) {
                  final plan = subscriptionPlans[index];
                  final isPopular = plan['popular'] as bool? ?? false;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildPlanCard(context, plan, isPopular),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Restore Purchases Button
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleRestorePurchases,
                icon: const Icon(Icons.restore),
                label: const Text('Restore Purchases'),
              ),
              const SizedBox(height: 16),
              // Manage Subscription Button
              OutlinedButton.icon(
                onPressed: () => _handleManageSubscription(),
                icon: const Icon(Icons.settings),
                label: const Text('Manage Subscription'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, Map plan, bool isPopular) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isPopular
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[600]!,
          width: isPopular ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isPopular
            ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
            : Colors.transparent,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Popular Badge
                if (isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Most Popular',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                if (isPopular) const SizedBox(height: 8),
                // Plan Name
                Text(
                  plan['name'],
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                // Price
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: plan['price'],
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextSpan(
                        text: plan['period'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[400],
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Stats
                _buildStatRow(context, 'Monthly Credits', plan['credits']),
                _buildStatRow(context, 'Max Prompts', plan['prompts']),
                _buildStatRow(context, 'Max Apps', plan['apps']),
                const SizedBox(height: 16),
                // Features
                ...List.generate(
                  (plan['features'] as List).length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            (plan['features'] as List)[i],
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Subscribe Button
                if (plan['tier'] != 'free')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => _handleSubscribe(plan['productId']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPopular
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        foregroundColor: isPopular ? Colors.white : null,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Subscribe'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[400],
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubscribe(String? productId) async {
    if (productId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final billingService = context.read<BillingService>();
      await billingService.buySubscription(productId: productId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription initiated!')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Subscription failed: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRestorePurchases() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final billingService = context.read<BillingService>();
      await billingService.restorePurchases();

      if (mounted) {
        // Refresh user data
        final userProvider = context.read<UserProvider>();
        await userProvider.refreshUserData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchases restored!')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Restore failed: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleManageSubscription() {
    final billingService = context.read<BillingService>();
    billingService.manageSubscription();
  }
}
