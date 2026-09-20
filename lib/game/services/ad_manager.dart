import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  AdManager._();

  static final AdManager instance = AdManager._();

  // ============================================================
  // PRODUCTION ADMOB IDs
  // ============================================================

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9973042638438490/8174012179';
    }

    // Core Barrage is currently Android-only.
    // Keep Google's test ID as fallback for non-Android platforms.
    return 'ca-app-pub-3940256099942544/2934735716';
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9973042638438490/9695986566';
    }

    return 'ca-app-pub-3940256099942544/4411468910';
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9973042638438490/9403333369';
    }

    return 'ca-app-pub-3940256099942544/1712485313';
  }

  // ============================================================
  // INTERSTITIAL
  // ============================================================

  InterstitialAd? _interstitialAd;

  bool _isInterstitialLoading = false;

  bool get isInterstitialReady =>
      _interstitialAd != null;

  void loadInterstitial() {
    if (_interstitialAd != null ||
        _isInterstitialLoading) {
      return;
    }

    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _isInterstitialLoading = false;
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (
            LoadAdError error,
            ) {
          _isInterstitialLoading = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitialAfterLevel({
    required int level,
    required void Function() onFinished,
  }) {
    // Interstitial ads start from Level 11.
    if (level <= 10) {
      onFinished();
      return;
    }

    final ad = _interstitialAd;

    if (ad == null) {
      loadInterstitial();
      onFinished();
      return;
    }

    _interstitialAd = null;

    bool finished = false;

    void finishOnce() {
      if (finished) {
        return;
      }

      finished = true;

      loadInterstitial();

      onFinished();
    }

    ad.fullScreenContentCallback =
        FullScreenContentCallback(
          onAdDismissedFullScreenContent: (
              Ad ad,
              ) {
            ad.dispose();
            finishOnce();
          },
          onAdFailedToShowFullScreenContent: (
              Ad ad,
              AdError error,
              ) {
            ad.dispose();
            finishOnce();
          },
        );

    ad.show();
  }

  // ============================================================
  // REWARDED AD
  // ============================================================

  RewardedAd? _rewardedAd;

  bool _isRewardedLoading = false;

  bool get isRewardedReady =>
      _rewardedAd != null;

  void loadRewarded() {
    if (_rewardedAd != null ||
        _isRewardedLoading) {
      return;
    }

    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback:
      RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _isRewardedLoading = false;
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (
            LoadAdError error,
            ) {
          _isRewardedLoading = false;
          _rewardedAd = null;
        },
      ),
    );
  }

  void showRewarded({
    required void Function() onRewardEarned,
    required void Function() onClosed,
  }) {
    final ad = _rewardedAd;

    if (ad == null) {
      loadRewarded();
      onClosed();
      return;
    }

    _rewardedAd = null;

    bool closed = false;

    void closeOnce() {
      if (closed) {
        return;
      }

      closed = true;

      loadRewarded();

      onClosed();
    }

    ad.fullScreenContentCallback =
        FullScreenContentCallback(
          onAdDismissedFullScreenContent: (
              Ad ad,
              ) {
            ad.dispose();
            closeOnce();
          },
          onAdFailedToShowFullScreenContent: (
              Ad ad,
              AdError error,
              ) {
            ad.dispose();
            closeOnce();
          },
        );

    ad.show(
      onUserEarnedReward: (
          AdWithoutView ad,
          RewardItem reward,
          ) {
        onRewardEarned();
      },
    );
  }

  // ============================================================
  // BANNER
  // ============================================================

  BannerAd createBannerAd({
    required void Function() onLoaded,
    required void Function(
        LoadAdError error,
        )
    onFailed,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (
            Ad ad,
            ) {
          onLoaded();
        },
        onAdFailedToLoad: (
            Ad ad,
            LoadAdError error,
            ) {
          ad.dispose();

          onFailed(
            error,
          );
        },
      ),
    );
  }

  // ============================================================
  // PRELOAD
  // ============================================================

  void preloadAds() {
    loadInterstitial();
    loadRewarded();
  }

  // ============================================================
  // CLEANUP
  // ============================================================

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;

    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
