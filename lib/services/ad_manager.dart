import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  AdManager._();

  static final AdManager instance = AdManager._();

  // Google official TEST ad IDs.
  // Replace these with real AdMob IDs before release.

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }

    return 'ca-app-pub-3940256099942544/2934735716';
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    }

    return 'ca-app-pub-3940256099942544/4411468910';
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    }

    return 'ca-app-pub-3940256099942544/1712485313';
  }

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  bool get isInterstitialReady => _interstitialAd != null;

  void loadInterstitial() {
    if (_interstitialAd != null || _isInterstitialLoading) {
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
        onAdFailedToLoad: (LoadAdError error) {
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

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (Ad ad) {
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

  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;

  bool get isRewardedReady => _rewardedAd != null;

  void loadRewarded() {
    if (_rewardedAd != null || _isRewardedLoading) {
      return;
    }

    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _isRewardedLoading = false;
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
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

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (Ad ad) {
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

  BannerAd createBannerAd({
    required void Function() onLoaded,
    required void Function(LoadAdError error) onFailed,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          onLoaded();
        },
        onAdFailedToLoad: (
            Ad ad,
            LoadAdError error,
            ) {
          ad.dispose();
          onFailed(error);
        },
      ),
    );
  }

  void preloadAds() {
    loadInterstitial();
    loadRewarded();
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;

    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}