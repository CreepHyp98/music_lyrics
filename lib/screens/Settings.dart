import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:music_lyrics/widgets/color_dialog.dart';
import 'package:music_lyrics/widgets/update_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:music_lyrics/class/banner_ad_manager.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    // バナー広告の読み込み
    BannerAd myBanner = createBannerAd();
    myBanner.load();

    return Stack(
      children: [
        ListView(
          children: [
            // 楽曲ライブラリの更新
            ListTile(
                leading: const Icon(Icons.autorenew),
                title: const Text('楽曲ライブラリの更新'),
                onTap: () {
                  // ダイアログ表示
                  showDialog(
                    // このダイアログは領域外タップ無効
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => UpdateDialog(
                      progress: 0.0,
                      doneOnce: true,
                    ),
                  );
                }),

            // アクセントカラー
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('アクセントカラー'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const ColorDialog(),
                );
              },
            ),

            // お問い合わせフォーム
            ListTile(
              leading: const Icon(Icons.send),
              title: const Text('お問い合わせフォーム'),
              onTap: () {
                // Google フォームを開く
                launchUrl(
                  Uri.parse('https://docs.google.com/forms/d/e/1FAIpQLSesGixlIAXYNodmKWg3jBOLPFVPvLylXKRzAskOtDDtYWGtOA/viewform?usp=sf_link'),
                );
              },
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: Text('developed by 太客')),
            const SizedBox(height: 2),
            // バナー広告
            SizedBox(
              height: myBanner.size.height.toDouble(),
              width: myBanner.size.width.toDouble(),
              child: AdWidget(ad: myBanner),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ],
    );
  }
}
