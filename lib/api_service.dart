import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

/// API Service for communicating with V Astra Create backend
class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio _dio;
  final Logger _logger = Logger();

  // Backend base URL - Updated with your live Render Server URL
  static const String baseUrl = 'https://v-astra-create-new.onrender.com';

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _initializeDio();
  }

  /// Initialize Dio with interceptors
  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
      ),
    );

    // Add request interceptor to attach Firebase token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              final token = await user.getIdToken();
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (e) {
            _logger.e('Error attaching token: $e');
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          _logger.e('API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  // ============================================================================
  // USER MANAGEMENT
  // ============================================================================

  /// Initialize or restore user from backend
  Future<Map<String, dynamic>> initUser() async {
    try {
      final response = await _dio.post('/api/user/init');
      _logger.i('User initialized: ${response.data}');
      return response.data;
    } catch (e) {
      _logger.e('Error initializing user: $e');
      rethrow;
    }
  }

  /// Get user profile and subscription status
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get('/api/user/profile');
      return response.data;
    } catch (e) {
      _logger.e('Error fetching profile: $e');
      rethrow;
    }
  }

  /// Get user apps list
  Future<List<Map<String, dynamic>>> getUserApps() async {
    try {
      final response = await _dio.get('/api/user/apps');
      final apps = (response.data['apps'] as List?)
          ?.cast<Map<String, dynamic>>() ??
          [];
      _logger.i('Fetched ${apps.length} apps');
      return apps;
    } catch (e) {
      _logger.e('Error fetching apps: $e');
      rethrow;
    }
  }

  // ============================================================================
  // APP GENERATION
  // ============================================================================

  /// Generate app from prompt using tier-based AI routing
  Future<Map<String, dynamic>> generateApp({
    required String prompt,
    required String appName,
  }) async {
    try {
      final response = await _dio.post(
        '/api/generate',
        data: {
          'prompt': prompt,
          'appName': appName,
        },
      );
      _logger.i('App generated: ${response.data['appId']}');
      return response.data;
    } catch (e) {
      _logger.e('Error generating app: $e');
      rethrow;
    }
  }

  /// Edit existing app with new prompt
  Future<Map<String, dynamic>> editApp({
    required String appId,
    required String editPrompt,
  }) async {
    try {
      final response = await _dio.post(
        '/api/edit/$appId',
        data: {
          'editPrompt': editPrompt,
        },
      );
      _logger.i('App edited: $appId');
      return response.data;
    } catch (e) {
      _logger.e('Error editing app: $e');
      rethrow;
    }
  }

  // ============================================================================
  // GOOGLE PLAY BILLING
  // ============================================================================

  /// Verify purchase token with backend
  Future<Map<String, dynamic>> verifyPurchase({
    required String purchaseToken,
    required String packageName,
    required String productId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/billing/verify-purchase',
        data: {
          'purchaseToken': purchaseToken,
          'packageName': packageName,
          'productId': productId,
        },
      );
      _logger.i('Purchase verified: ${response.data['tier']}');
      return response.data;
    } catch (e) {
      _logger.e('Error verifying purchase: $e');
      rethrow;
    }
  }

  /// Restore purchases from Google Play
  Future<Map<String, dynamic>> restorePurchases({
    required List<Map<String, String>> purchaseTokens,
  }) async {
    try {
      final response = await _dio.post(
        '/api/billing/restore-purchases',
        data: {
          'purchaseTokens': purchaseTokens,
        },
      );
      _logger.i('Purchases restored: ${response.data['tier']}');
      return response.data;
    } catch (e) {
      _logger.e('Error restoring purchases: $e');
      rethrow;
    }
  }

  /// Get subscription status
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    try {
      final response = await _dio.get('/api/billing/subscription-status');
      return response.data;
    } catch (e) {
      _logger.e('Error fetching subscription status: $e');
      rethrow;
    }
  }

  // ============================================================================
  // APP PUBLISHING
  // ============================================================================

  /// Publish app to shareable link
  Future<Map<String, dynamic>> publishApp({
    required String appId,
  }) async {
    try {
      final response = await _dio.post('/api/publish/$appId');
      _logger.i('App published: ${response.data['publishedUrl']}');
      return response.data;
    } catch (e) {
      _logger.e('Error publishing app: $e');
      rethrow;
    }
  }

  /// Get published app
  Future<Map<String, dynamic>> getPublishedApp({
    required String shareId,
  }) async {
    try {
      final response = await _dio.get('/api/published/$shareId');
      return response.data;
    } catch (e) {
      _logger.e('Error fetching published app: $e');
      rethrow;
    }
  }

  /// Get app details
  Future<Map<String, dynamic>> getAppDetails(String appId) async {
    try {
      final response = await _dio.get('/api/app/$appId');
      return response.data;
    } catch (e) {
      _logger.e('Error fetching app details: $e');
      rethrow;
    }
  }

  // ============================================================================
  // ANALYTICS
  // ============================================================================

  /// Track app view
  Future<void> trackAppView(String shareId) async {
    try {
      await _dio.post('/api/analytics/view', data: {'shareId': shareId});
    } catch (e) {
      _logger.e('Error tracking view: $e');
    }
  }

  /// Get app analytics
  Future<Map<String, dynamic>> getAppAnalytics(String appId) async {
    try {
      final response = await _dio.get('/api/analytics/$appId');
      return response.data;
    } catch (e) {
      _logger.e('Error fetching analytics: $e');
      rethrow;
    }
  }

  // ============================================================================
  // HEALTH CHECK
  // ============================================================================

  /// Check backend health
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/api/health');
      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Health check failed: $e');
      return false;
    }
  }
}
