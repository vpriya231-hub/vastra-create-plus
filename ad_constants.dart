/// AdMob Configuration Constants
/// Replace test IDs with your live AdMob IDs in production

class AdConstants {
  // ============================================================================
  // AdMob APP IDs
  // ============================================================================
  
  /// AdMob App ID for Android
  /// Replace with your actual AdMob App ID from AdMob Console
  static const String androidAdMobAppId = 'ca-app-pub-3940256099942544~3347511713';
  
  /// AdMob App ID for iOS
  /// Replace with your actual AdMob App ID from AdMob Console
  static const String iosAdMobAppId = 'ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy';
  
  // ============================================================================
  // BANNER AD UNIT IDs (Free Plan Only)
  // ============================================================================
  
  /// Android Banner Ad Unit ID (Test)
  /// Replace with: ca-app-pub-3940256099942544/6300978111 (production)
  static const String androidBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  
  /// iOS Banner Ad Unit ID (Test)
  /// Replace with: ca-app-pub-3940256099942544/2934735716 (production)
  static const String iosBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716';
  
  // ============================================================================
  // INTERSTITIAL AD UNIT IDs (Free Plan Only)
  // ============================================================================
  
  /// Android Interstitial Ad Unit ID (Test)
  /// Replace with: ca-app-pub-3940256099942544/1033173712 (production)
  static const String androidInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  
  /// iOS Interstitial Ad Unit ID (Test)
  /// Replace with: ca-app-pub-3940256099942544/4411468910 (production)
  static const String iosInterstitialAdUnitId = 'ca-app-pub-3940256099942544/4411468910';
  
  // ============================================================================
  // REWARDED AD UNIT IDs (Free Plan - Downloads/Publishing Only)
  // ============================================================================
  
  /// Android Rewarded Ad Unit ID (Test)
  /// Replace with: ca-app-pub-3940256099942544/5224354917 (production)
  static const String androidRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  
  /// iOS Rewarded Ad Unit ID (Test)
  /// Replace with: ca-app-pub-3940256099942544/1712485313 (production)
  static const String iosRewardedAdUnitId = 'ca-app-pub-3940256099942544/1712485313';
  
  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Get Banner Ad Unit ID based on platform
  static String getBannerAdUnitId() {
    return _getPlatformSpecificId(androidBannerAdUnitId, iosBannerAdUnitId);
  }
  
  /// Get Interstitial Ad Unit ID based on platform
  static String getInterstitialAdUnitId() {
    return _getPlatformSpecificId(androidInterstitialAdUnitId, iosInterstitialAdUnitId);
  }
  
  /// Get Rewarded Ad Unit ID based on platform
  static String getRewardedAdUnitId() {
    return _getPlatformSpecificId(androidRewardedAdUnitId, iosRewardedAdUnitId);
  }
  
  /// Internal helper to get platform-specific ID
  static String _getPlatformSpecificId(String androidId, String iosId) {
    // This will be implemented in the actual app with platform detection
    // For now, return Android ID as default
    return androidId;
  }
  
  // ============================================================================
  // AD DISPLAY CONFIGURATION
  // ============================================================================
  
  /// Maximum number of banner ads to show per session
  static const int maxBannerAdsPerSession = 5;
  
  /// Minimum time (in seconds) between interstitial ads
  static const int interstitialMinIntervalSeconds = 30;
  
  /// Show rewarded ad before download/publish (Free tier only)
  static const bool showRewardedBeforeDownload = true;
  
  /// Reward amount for watching rewarded video
  static const int rewardAmount = 1;
}
