import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v_astra_create/providers/user_provider.dart';
import 'package:v_astra_create/services/admob_service.dart';

/// App generation page with prompt input and credit deduction
class GeneratePage extends StatefulWidget {
  const GeneratePage({Key? key}) : super(key: key);

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  final _appNameController = TextEditingController();
  final _promptController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _appNameController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate New App'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Describe your app idea',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Provide a clear description of what you want your app to do. Be specific about features and functionality.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[400],
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // App Name Input
              Text(
                'App Name',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _appNameController,
                decoration: InputDecoration(
                  hintText: 'e.g., Todo List, Weather App',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.app_registration),
                ),
                maxLength: 50,
              ),
              const SizedBox(height: 24),
              // Prompt Input
              Text(
                'App Description',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _promptController,
                decoration: InputDecoration(
                  hintText: 'Describe your app idea in detail...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 6,
                maxLength: 1000,
              ),
              const SizedBox(height: 24),
              // Credit Cost Info
              Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[300], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This will cost 1 credit. You have ${userProvider.userData?.remainingCredits ?? 0} credits available.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.blue[300],
                                ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
              // Generate Button
              Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  return ElevatedButton.icon(
                    onPressed: (_isLoading || !userProvider.hasCredits)
                        ? null
                        : () => _handleGenerate(context, userProvider),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      _isLoading ? 'Generating...' : 'Generate App (1 Credit)',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Cancel Button
              OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleGenerate(BuildContext context, UserProvider userProvider) async {
    // Validate inputs
    if (_appNameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an app name';
      });
      return;
    }

    if (_promptController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an app description';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Generate app (credit will be deducted by backend)
      final result = await userProvider.generateApp(
        appName: _appNameController.text,
        prompt: _promptController.text,
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('App generated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to app preview
        Navigator.of(context).pushReplacementNamed(
          '/app-preview',
          arguments: result,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Generation failed: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
