import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/screens/LyricEdit.dart';
import 'package:music_lyrics/widgets/NavigatonBar.dart';
import 'package:path_provider/path_provider.dart';
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
  directory = await getApplicationDocumentsDirectory();
  getSplashText();

  // メディア通知のセットアップ
  // TODO: 歌詞編集用の再生でもMediaItemを指定しなくちゃいけなくなっちゃう
  // TODO: 曲リストから再生するときのみメディア通知を出したい
  //await JustAudioBackground.init(
  //  androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
  //  androidNotificationChannelName: 'Audio playback',
  //  androidNotificationOngoing: true,
  //);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // 定数コンストラクタ
  const MyApp({super.key});

  // widgetの生成
  @override
  Widget build(BuildContext context) {
    // 端末のサイズを取得
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    // アプリケーション全体
    return MaterialApp(
      // テーマデータ
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "Noto Sans JP",
      ),
      // 構成画面
      routes: <String, WidgetBuilder>{
        '/': (_) => const Splash(),
        '/home': (_) => const NavBarWidget(),
        '/edit': (_) => const LyricEdit(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<void> getSplashText() async {
  SplashTextList = prefs.getStringList('splash') ?? ['', '', ''];
}
