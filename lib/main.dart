import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_lyrics/widgets/NavBarWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'provider/provider.dart';
import 'screens/Splash.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  // スプラッシュ画面の表示が終わるまでステータスバーとナビゲーションバーを非表示
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

  // インスタンス生成
  prefs = await SharedPreferences.getInstance();
  await getSplashText();

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
  const MyApp({super.key});

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
      routes: <String, WidgetBuilder>{
        '/': (_) => const Splash(),
        '/home': (_) => const NavBarWidget(),
      },
    );
  }
}

Future<void> getSplashText() async {
  SplashTextList = prefs.getStringList('splash') ?? ['', '', ''];
}
