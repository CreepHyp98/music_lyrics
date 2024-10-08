import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/widgets/vertical_rotated_writing.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();

    // スプラッシュ画面を表示
    Future.delayed(const Duration(seconds: 2, milliseconds: 0), () {
      // 遷移元の画面を破棄してホーム画面へ
      Navigator.of(context).pushReplacementNamed("/home");
      // ステータスバーとナビゲーションバーの非表示終了
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: splashTextList[1] == ''
            // 空なら
            ? const Align(
                alignment: Alignment(0.0, -0.4),
                child: VerticalRotatedWriting(
                  fontSize: 24,
                  text: 'あなたの歌詞が',
                ),
              )
            // 登録データがあるなら
            : Stack(
                children: [
                  // 歌詞
                  const Align(
                    alignment: Alignment(0.0, -0.4),
                    child: VerticalRotatedWriting(
                      fontSize: 20,
                      text: 'ダミー歌詞',
                    ),
                  ),

                  // 曲名／アーティスト名
                  Align(
                    alignment: const Alignment(-0.5, 0.4),
                    child: VerticalRotatedWriting(
                      fontSize: 18,
                      text: "${splashTextList[1]}／${splashTextList[2]}",
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
