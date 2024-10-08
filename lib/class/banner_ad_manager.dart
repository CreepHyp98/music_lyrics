import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

BannerAd createBannerAd() {
  return BannerAd(
    adUnitId: getAdBannerUnitId(),
    size: AdSize.banner,
    request: const AdRequest(),
    listener: BannerAdListener(
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
      },
    ),
  );
}

// プラットフォーム（iOS / Android）に合わせて広告IDを返す
String getAdBannerUnitId() {
  String adUnitId = "";

  if (Platform.isAndroid) {
    // Android のとき
    adUnitId = "ca-app-pub-2338849205545790/3678213564";
  } else if (Platform.isIOS) {
    // iOSのとき
    adUnitId = "ca-app-pub-2338849205545790/2959742855";
  }
  return adUnitId;
}
