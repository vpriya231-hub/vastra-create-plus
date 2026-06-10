import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v_astra_create/services/firebase_service.dart';

/// Settings page with legal links and user options
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Account Section
            _buildSection(
              context,
              title: 'Account',
              children: [
                _buildTile(
                  context,
                  icon: Icons.person,
                  title: 'Profile',
                  subtitle: 'View and edit your profile',
                  onTap: () {},
                ),
                _buildTile(
                  context,
                  icon: Icons.security,
                  title: 'Security',
                  subtitle: 'Manage password and security',
                  onTap: () {},
                ),
              ],
            ),
            // Subscription Section
            _buildSection(
              context,
              title: 'Subscription',
              children: [
                _buildTile(
                  context,
                  icon: Icons.card_membership,
                  title: 'Manage Subscription',
                  subtitle: 'View and manage your plan',
                  onTap: () => Navigator.of(context).pushNamed('/subscription'),
                ),
                _buildTile(
                  context,
                  icon: Icons.history,
                  title: 'Billing History',
                  subtitle: 'View your invoices and transactions',
                  onTap: () {},
                ),
              ],
            ),
            // Legal Section
            _buildSection(
              context,
              title: 'Legal & About',
              children: [
                _buildTile(
                  context,
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () => _openLegalLink(
                    context,
                    'https://sites.google.com/view/v-astra-create-privacy-policy/home',
                  ),
                ),
                _buildTile(
                  context,
                  icon: Icons.description,
                  title: 'Terms & Conditions',
                  subtitle: 'Read our terms and conditions',
                  onTap: () => _openLegalLink(
                    context,
                    'https://sites.google.com/view/v-astra-create-terms/home',
                  ),
                ),
                _buildTile(
                  context,
                  icon: Icons.info,
                  title: 'About',
                  subtitle: 'About V Astra Create',
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
            // App Section
            _buildSection(
              context,
              title: 'App',
              children: [
                _buildTile(
                  context,
                  icon: Icons.bug_report,
                  title: 'Report Bug',
                  subtitle: 'Report a bug or issue',
                  onTap: () {},
                ),
                _buildTile(
                  context,
                  icon: Icons.feedback,
                  title: 'Send Feedback',
                  subtitle: 'Share your feedback with us',
                  onTap: () {},
                ),
                _buildTile(
                  context,
                  icon: Icons.star,
                  title: 'Rate App',
                  subtitle: 'Rate us on Google Play Store',
                  onTap: () {},
                ),
              ],
            ),
            // Danger Zone
            _buildSection(
              context,
              title: 'Danger Zone',
              children: [
                _buildTile(
                  context,
                  icon: Icons.logout,
                  title: 'Sign Out',
                  subtitle: 'Sign out from your account',
                  onTap: () => _handleSignOut(context),
                  isDestructive: true,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
          fontWeight: isDestructive ? FontWeight.bold : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _openLegalLink(BuildContext context, String url) {
    // TODO: Implement in-app browser using flutter_inappwebview
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening: $url')),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'V Astra Create',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 V Astra Create. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        Text(
          'Transform Ideas into Apps with AI',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final firebaseService = context.read<FirebaseService>();
        await firebaseService.signOut();

        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign out failed: $e')),
        );
      }
    }
  }
}
