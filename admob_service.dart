import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:v_astra_create/constants/ad_constants.dart';

/// AdMob Service for managing advertisements
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  final Logger _logger = Logger();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isBannerAdReady = false;
  bool _isInterstitialAdReady = false;
  bool _isRewardedAdReady = false;

  factory AdMobService() {
    return _instance;
  }

  AdMobService._internal();

  /// Initialize Google Mobile Ads SDK
  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      _logger.i('Google Mobile Ads SDK initialized');
    } catch (e) {
      _logger.e('Error initializing Google Mobile Ads: $e');
    }
  }

  // ============================================================================
  // BANNER ADS (Free Plan Only)
  // ============================================================================

  /// Load banner ad (for free tier users only)
  void loadBannerAd({required bool showForFreeTierOnly}) {
    if (!showForFreeTierOnly) {
      _logger.i('Banner ads disabled for paid tier');
      return;
    }

    _logger.i('Loading banner ad for free tier users');

    _bannerAd = BannerAd(
      adUnitId: AdConstants.getBannerAdUnitId(),
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdReady = true;
          _logger.i('Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          _logger.e('Banner ad failed to load: ${error.message}');
          ad.dispose();
          _bannerAd = null;
        },
      ),
    );

    _bannerAd?.load();
  }

  /// Get banner ad widget
  BannerAd? get bannerAd => _isBannerAdReady ? _bannerAd : null;

  /// Dispose banner ad
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdReady = false;
  }

  // ============================================================================
  // INTERSTITIAL ADS (Free Plan Only)
  // ============================================================================

  /// Load interstitial ad (for free tier users only)
  void loadInterstitialAd({required bool showForFreeTierOnly}) {
    if (!showForFreeTierOnly) {
      _logger.i('Interstitial ads disabled for paid tier');
      return;
    }

    _logger.i('Loading interstitial ad for free tier users');

    InterstitialAd.load(
      adUnitId: AdConstants.getInterstitialAdUnitId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _logger.i('Interstitial ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _logger.e('Interstitial ad failed to load: ${error.message}');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  /// Show interstitial ad (for free tier users)
  Future<void> showInterstitialAd() async {
    if (!_isInterstitialAdReady || _interstitialAd == null) {
      _logger.w('Interstitial ad not ready');
      return;
    }

    _logger.i('Showing interstitial ad to free tier user');

    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _logger.i('Interstitial ad dismissed');
        ad.dispose();
        _isInterstitialAdReady = false;
        // Reload for next time
        loadInterstitialAd(showForFreeTierOnly: true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _logger.e('Interstitial ad failed to show: ${error.message}');
        ad.dispose();
        _isInterstitialAdReady = false;
      },
    );

    await _interstitialAd?.show();
  }

  // ============================================================================
  // REWARDED ADS (Free Plan - Downloads/Publishing Only)
  // ============================================================================

  /// Load rewarded ad (for free tier users during downloads)
  void loadRewardedAd({required bool showForFreeTierOnly}) {
    if (!showForFreeTierOnly) {
      _logger.i('Rewarded ads disabled for paid tier');
      return;
    }

    _logger.i('Loading rewarded ad for free tier download trigger');

    RewardedAd.load(
      adUnitId: AdConstants.getRewardedAdUnitId(),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          _logger.i('Rewarded ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _logger.e('Rewarded ad failed to load: ${error.message}');
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  /// Show rewarded ad for app download (FREE TIER ONLY)
  /// CRITICAL: This is strictly triggered ONLY during downloads for free tier users
  Future<bool> showRewardedAdForDownload({
    required bool isFreeTier,
    required Function() onRewardEarned,
  }) async {
    // CRITICAL: Only show for free tier users
    if (!isFreeTier) {
      _logger.i('Rewarded ad skipped: User is not on free tier');
      return true; // Skip ad, allow download
    }

    if (!_isRewardedAdReady || _rewardedAd == null) {
      _logger.w('Rewarded ad not ready, allowing download without ad');
      return true; // Allow download if ad not ready
    }

    bool rewardEarned = false;

    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _logger.i('Rewarded ad dismissed');
        ad.dispose();
        _isRewardedAdReady = false;
        // Reload for next time
        loadRewardedAd(showForFreeTierOnly: true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _logger.e('Rewarded ad failed to show: ${error.message}');
        ad.dispose();
        _isRewardedAdReady = false;
      },
    );

    await _rewardedAd?.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        rewardEarned = true;
        _logger.i('User earned reward: ${reward.amount} ${reward.type}');
        onRewardEarned();
      },
    );

    return rewardEarned;
  }

  /// Check if rewarded ad is ready
  bool get isRewardedAdReady => _isRewardedAdReady;

  // ============================================================================
  // CLEANUP
  // ============================================================================

  /// Dispose all ads
  void disposeAll() {
    disposeBannerAd();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _isInterstitialAdReady = false;
    _isRewardedAdReady = false;
    _logger.i('All ads disposed');
  }
}
