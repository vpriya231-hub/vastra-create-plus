import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v_astra_create/services/api_service.dart';
import 'package:v_astra_create/services/firebase_service.dart';
import 'package:logger/logger.dart';

/// User data model
class UserData {
  final String uid;
  final String email;
  final String tier;
  final int remainingCredits;
  final int maxPrompts;
  final int totalPrompts;
  final List<AppModel> apps;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserData({
    required this.uid,
    required this.email,
    required this.tier,
    required this.remainingCredits,
    required this.maxPromits,
    required this.totalPrompts,
    required this.apps,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      tier: json['tier'] ?? 'free',
      remainingCredits: json['remainingCredits'] ?? 0,
      maxPromits: json['maxPrompts'] ?? 5,
      totalPrompts: json['totalPrompts'] ?? 0,
      apps: (json['apps'] as List?)?.map((a) => AppModel.fromJson(a)).toList() ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'tier': tier,
      'remainingCredits': remainingCredits,
      'maxPrompts': maxPrompts,
      'totalPrompts': totalPrompts,
      'apps': apps.map((a) => a.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserData copyWith({
    String? uid,
    String? email,
    String? tier,
    int? remainingCredits,
    int? maxPrompts,
    int? totalPrompts,
    List<AppModel>? apps,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserData(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      tier: tier ?? this.tier,
      remainingCredits: remainingCredits ?? this.remainingCredits,
      maxPromits: maxPrompts ?? this.maxPrompts,
      totalPrompts: totalPrompts ?? this.totalPrompts,
      apps: apps ?? this.apps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// App model
class AppModel {
  final String appId;
  final String appName;
  final String prompt;
  final String html;
  final String provider;
  final DateTime createdAt;
  final bool isPublished;
  final String? publishedUrl;
  final String? shareId;

  AppModel({
    required this.appId,
    required this.appName,
    required this.prompt,
    required this.html,
    required this.provider,
    required this.createdAt,
    required this.isPublished,
    this.publishedUrl,
    this.shareId,
  });

  factory AppModel.fromJson(Map<String, dynamic> json) {
    return AppModel(
      appId: json['appId'] ?? '',
      appName: json['appName'] ?? '',
      prompt: json['prompt'] ?? '',
      html: json['html'] ?? '',
      provider: json['provider'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isPublished: json['isPublished'] ?? false,
      publishedUrl: json['publishedUrl'],
      shareId: json['shareId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'appName': appName,
      'prompt': prompt,
      'html': html,
      'provider': provider,
      'createdAt': createdAt.toIso8601String(),
      'isPublished': isPublished,
      'publishedUrl': publishedUrl,
      'shareId': shareId,
    };
  }
}

/// User provider for state management
class UserProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  final ApiService _apiService;
  final Logger _logger = Logger();

  UserData? _userData;
  bool _isLoading = false;
  String? _error;

  UserProvider({
    required FirebaseService firebaseService,
    required ApiService apiService,
  })  : _firebaseService = firebaseService,
        _apiService = apiService;

  // Getters
  UserData? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseService.isAuthenticated;
  bool get hasCredits => (_userData?.remainingCredits ?? 0) > 0;
  bool get isFreeTier => (_userData?.tier ?? 'free') == 'free';

  /// Initialize user on app startup
  Future<void> initializeUser() async {
    if (!isAuthenticated) {
      _logger.i('User not authenticated');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final profile = await _apiService.getUserProfile();
      _userData = UserData.fromJson(profile);
      _logger.i('User initialized: ${_userData?.tier}');
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize user: $e');
      _logger.e('User initialization error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh user data from backend
  Future<void> refreshUserData() async {
    _setLoading(true);
    _clearError();

    try {
      final profile = await _apiService.getUserProfile();
      _userData = UserData.fromJson(profile);
      _logger.i('User data refreshed');
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh user data: $e');
      _logger.e('Refresh error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Generate app and deduct credit
  Future<Map<String, dynamic>> generateApp({
    required String appName,
    required String prompt,
  }) async {
    if (!hasCredits) {
      _setError('Insufficient credits');
      throw Exception('Insufficient credits');
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _apiService.generateApp(
        prompt: prompt,
        appName: appName,
      );

      // Update local state
      final newApp = AppModel(
        appId: result['appId'],
        appName: appName,
        prompt: prompt,
        html: result['html'],
        provider: result['provider'],
        createdAt: DateTime.now(),
        isPublished: false,
      );

      _userData = _userData?.copyWith(
        remainingCredits: result['remainingCredits'] ?? 0,
        totalPrompts: result['totalPrompts'] ?? 0,
        apps: [...(_userData?.apps ?? []), newApp],
      );

      _logger.i('App generated: ${result['appId']}');
      notifyListeners();

      return result;
    } catch (e) {
      _setError('Generation failed: $e');
      _logger.e('Generation error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Edit app and deduct credit
  Future<Map<String, dynamic>> editApp({
    required String appId,
    required String editPrompt,
  }) async {
    if (!hasCredits) {
      _setError('Insufficient credits');
      throw Exception('Insufficient credits');
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _apiService.editApp(
        appId: appId,
        editPrompt: editPrompt,
      );

      // Update local state
      final updatedApps = _userData?.apps.map((app) {
        if (app.appId == appId) {
          return AppModel(
            appId: app.appId,
            appName: app.appName,
            prompt: editPrompt,
            html: result['html'],
            provider: result['provider'],
            createdAt: app.createdAt,
            isPublished: app.isPublished,
            publishedUrl: app.publishedUrl,
            shareId: app.shareId,
          );
        }
        return app;
      }).toList();

      _userData = _userData?.copyWith(
        remainingCredits: result['remainingCredits'] ?? 0,
        totalPrompts: result['totalPrompts'] ?? 0,
        apps: updatedApps,
      );

      _logger.i('App edited: $appId');
      notifyListeners();

      return result;
    } catch (e) {
      _setError('Edit failed: $e');
      _logger.e('Edit error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Publish app
  Future<Map<String, dynamic>> publishApp({required String appId}) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _apiService.publishApp(appId: appId);

      // Update local state
      final updatedApps = _userData?.apps.map((app) {
        if (app.appId == appId) {
          return AppModel(
            appId: app.appId,
            appName: app.appName,
            prompt: app.prompt,
            html: app.html,
            provider: app.provider,
            createdAt: app.createdAt,
            isPublished: true,
            publishedUrl: result['publishedUrl'],
            shareId: result['shareId'],
          );
        }
        return app;
      }).toList();

      _userData = _userData?.copyWith(apps: updatedApps);

      _logger.i('App published: $appId');
      notifyListeners();

      return result;
    } catch (e) {
      _setError('Publish failed: $e');
      _logger.e('Publish error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Update user tier after purchase
  Future<void> updateTierAfterPurchase({required String tier}) async {
    _setLoading(true);
    _clearError();

    try {
      await refreshUserData();
      _logger.i('Tier updated to: $tier');
    } catch (e) {
      _setError('Failed to update tier: $e');
      _logger.e('Tier update error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
      _userData = null;
      _clearError();
      _logger.i('User signed out');
      notifyListeners();
    } catch (e) {
      _setError('Sign out failed: $e');
      _logger.e('Sign out error: $e');
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
