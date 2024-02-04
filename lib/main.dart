import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:music_lyrics/screens/lyric_edit.dart';
import 'package:music_lyrics/widgets/bottom_nav_bar.dart';
import 'package:music_lyrics/widgets/color_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'provider/provider.dart';
import 'screens/splash.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  // スプラッシュ画面の表示が終わるまでステータスバーとナビゲーションバーを非表示
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

  // インスタンス生成
  prefs = await SharedPreferences.getInstance();
  MobileAds.instance.initialize();

  getSplashText();

  // AudioPlayerのグローバル設定
  const AudioContext audioContext = AudioContext(
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: [
        AVAudioSessionOptions.defaultToSpeaker,
        AVAudioSessionOptions.mixWithOthers,
      ],
    ),
    android: AudioContextAndroid(
      isSpeakerphoneOn: true,
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.media,
      audioFocus: AndroidAudioFocus.gain,
    ),
  );
  AudioPlayer.global.setAudioContext(audioContext);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  // 定数コンストラクタ
  const MyApp({super.key});

  // widgetの生成
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 端末のサイズを取得
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    // アプリケーション全体
    return MaterialApp(
      // テーマデータ
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "Noto Sans JP",
        colorScheme: createColorScheme(ref.watch(colorValueProvider)),
      ),
      // 構成画面
      routes: <String, WidgetBuilder>{
        '/': (_) => const Splash(),
        '/home': (_) => const BottomNavBar(),
        '/edit': (_) => const LyricEdit(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<void> getSplashText() async {
  splashTextList = prefs.getStringList('splash') ?? ['', '', ''];
}
