import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logger/logger.dart';
import 'package:v_astra_create/services/api_service.dart';

/// Google Play Billing Service for subscription management
class BillingService {
  static final BillingService _instance = BillingService._internal();
  final Logger _logger = Logger();
  final ApiService _apiService = ApiService();
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  // Google Play Product IDs
  static const String plusProductId = 'v_astra_plus_monthly';
  static const String proProductId = 'v_astra_pro_monthly';
  static const String ultraProductId = 'v_astra_ultra_monthly';

  late Stream<List<PurchaseDetails>> _purchaseStream;
  bool _isAvailable = false;

  factory BillingService() {
    return _instance;
  }

  BillingService._internal();

  /// Initialize billing service
  Future<void> initialize() async {
    try {
      _isAvailable = await _inAppPurchase.isAvailable();

      if (_isAvailable) {
        _purchaseStream = _inAppPurchase.purchaseStream;
        _purchaseStream.listen(
          _handlePurchaseUpdate,
          onError: (error) {
            _logger.e('Purchase stream error: $error');
          },
        );
        _logger.i('Billing service initialized');
      } else {
        _logger.w('In-app purchases not available');
      }
    } catch (e) {
      _logger.e('Error initializing billing: $e');
    }
  }

  /// Get available products
  Future<ProductDetailsResponse> getProducts() async {
    if (!_isAvailable) {
      _logger.w('In-app purchases not available');
      return ProductDetailsResponse(
        productDetails: [],
        notFoundIDs: [plusProductId, proProductId, ultraProductId],
      );
    }

    try {
      final response = await _inAppPurchase.queryProductDetails({
        plusProductId,
        proProductId,
        ultraProductId,
      });

      _logger.i('Products loaded: ${response.productDetails.length}');
      return response;
    } catch (e) {
      _logger.e('Error fetching products: $e');
      rethrow;
    }
  }

  // ============================================================================
  // SUBSCRIPTION PURCHASE
  // ============================================================================

  /// Buy subscription
  Future<void> buySubscription({required String productId}) async {
    if (!_isAvailable) {
      _logger.w('In-app purchases not available');
      throw Exception('In-app purchases not available');
    }

    try {
      final productDetails = await _getProductDetails(productId);

      if (productDetails == null) {
        throw Exception('Product not found: $productId');
      }

      final purchaseParam = PurchaseParam(productDetails: productDetails);
      await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);

      _logger.i('Purchase initiated for: $productId');
    } catch (e) {
      _logger.e('Error buying subscription: $e');
      rethrow;
    }
  }

  /// Get product details
  Future<ProductDetails?> _getProductDetails(String productId) async {
    try {
      final response = await getProducts();
      return response.productDetails.firstWhere(
        (product) => product.id == productId,
        orElse: () => null as ProductDetails,
      );
    } catch (e) {
      _logger.e('Error getting product details: $e');
      return null;
    }
  }

  // ============================================================================
  // PURCHASE HANDLING
  // ============================================================================

  /// Handle purchase updates
  Future<void> _handlePurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        _logger.i('Purchase pending: ${purchase.productID}');
      } else if (purchase.status == PurchaseStatus.error) {
        _logger.e('Purchase error: ${purchase.error}');
        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Verify purchase with backend
        await _verifyPurchaseWithBackend(purchase);

        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchase);
        }
      }
    }
  }

  /// Verify purchase with backend and update user tier
  Future<void> _verifyPurchaseWithBackend(PurchaseDetails purchase) async {
    try {
      final result = await _apiService.verifyPurchase(
        purchaseToken: purchase.verificationData.serverVerificationData,
        packageName: 'com.vastra.create',
        productId: purchase.productID,
      );

      _logger.i('Purchase verified: ${result['tier']}');
      _logger.i('New credits: ${result['remainingCredits']}');
      _logger.i('New max prompts: ${result['maxPrompts']}');
    } catch (e) {
      _logger.e('Error verifying purchase: $e');
    }
  }

  // ============================================================================
  // RESTORE PURCHASES
  // ============================================================================

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      _logger.w('In-app purchases not available');
      throw Exception('In-app purchases not available');
    }

    try {
      await _inAppPurchase.restorePurchases();
      _logger.i('Purchases restored');
    } catch (e) {
      _logger.e('Error restoring purchases: $e');
      rethrow;
    }
  }

  // ============================================================================
  // SUBSCRIPTION MANAGEMENT
  // ============================================================================

  /// Open Google Play subscription management page
  Future<void> manageSubscription() async {
    try {
      // This will open the Google Play Store app to manage subscriptions
      // Implementation depends on platform-specific code
      _logger.i('Opening subscription management');
    } catch (e) {
      _logger.e('Error opening subscription management: $e');
    }
  }

  /// Get subscription status
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    try {
      return await _apiService.getSubscriptionStatus();
    } catch (e) {
      _logger.e('Error getting subscription status: $e');
      rethrow;
    }
  }

  /// Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
    try {
      final status = await getSubscriptionStatus();
      return status['isActive'] ?? false;
    } catch (e) {
      _logger.e('Error checking subscription: $e');
      return false;
    }
  }

  /// Dispose billing service
  void dispose() {
    _logger.i('Billing service disposed');
  }
}
