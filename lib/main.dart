import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'screens/AllSongs.dart';

Future<void> main() async {
  // メディア通知のセットアップ
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // 定数コンストラクタ
  const MyApp({Key? key}) : super(key: key);

  // widgetの生成
  @override
  Widget build(BuildContext context) {
    // アプリケーション全体
    return MaterialApp(
      // テーマデータ
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "Noto Sans JP",
      ),
      // 初期表示のクラス
      home: const AllSongs(),
    );
  }
}
