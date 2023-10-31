import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:music_lyrics/screens/LyricEdit.dart';
import 'package:music_lyrics/widgets/NavigatonBar.dart';
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
  MobileAds.instance.initialize();

  getSplashText();

  // AudioPlayerのグローバル設定
  const AudioContext audioContext = AudioContext(
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: [
        AVAudioSessionOptions.defaultToSpeaker,
        AVAudioSessionOptions.mixWithOthers,
        //AVAudioSessionOptions.allowAirPlay,
        //AVAudioSessionOptions.allowBluetooth,
        //AVAudioSessionOptions.allowBluetoothA2DP,
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
        colorSchemeSeed: Color(ref.watch(ColorValueProvider)),
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
