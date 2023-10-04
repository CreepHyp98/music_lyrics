import 'package:flutter/material.dart';
import 'package:music_lyrics/widgets/UpdateDialog.dart';

import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          children: [
            // ライブラリ更新
            ListTile(
              leading: const Icon(Icons.autorenew),
              title: const Text('楽曲ライブラリの更新'),
              onTap: () {
                // ダイアログ表示
                showDialog(
                  context: context,
                  builder: (context) => UpdateDialog(
                    progress: 0.0,
                    doneOnce: true,
                  ),
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

        // バージョン情報
        const Align(
          alignment: Alignment.bottomCenter,
          child: Text('developed by 40'),
        ),
      ],
    );
  }
}
