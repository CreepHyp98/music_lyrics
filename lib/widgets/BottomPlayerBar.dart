import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:music_lyrics/class/BannerAdManager.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

class BottomPlayerBar extends ConsumerStatefulWidget {
  const BottomPlayerBar({super.key});

  @override
  ConsumerState<BottomPlayerBar> createState() => _BottomPlayerBarState();
}

class _BottomPlayerBarState extends ConsumerState<BottomPlayerBar> {
  int? _duration;
  bool _isPlaying = false;

  void listenToSongStream() {
    // 音源ファイルの曲時間を取得
    _duration = ref.watch(EditSongProvider).duration;

    // 現在の再生位置を取得
    EditAudioPlayer.onPositionChanged.listen((position) {
      // このmountedがないとエラーになる
      if (mounted) {
        ref.read(EditPosiProvider.notifier).state = position;
      }
    });

    // 再生終了後
    audioPlayer.onPlayerComplete.listen((event) {
      // このmountedがないとエラーになる
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // バナー広告の読み込み
    BannerAd myBanner = createBannerAd();
    myBanner.load();

    // 再生状況の取得
    listenToSongStream();

    return BottomAppBar(
      // 画面スクロールで色が変わるのを防ぐ
      elevation: 0,
      // 下側の余白のみ削除
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
      height: deviceHeight * 0.16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // SliderThemeでスライダーをラップ
          SliderTheme(
            // 上下のパディングをなくす
            data: SliderThemeData(overlayShape: SliderComponentShape.noOverlay),

            child: Slider(
              value: ref.watch(EditPosiProvider).inMilliseconds.toDouble(),
              max: _duration!.toDouble(),
              onChanged: (value) {
                EditAudioPlayer.seek(Duration(milliseconds: value.toInt()));
              },
            ),
          ),
          Row(
            children: [
              // 再生・停止ボタン
              IconButton(
                onPressed: () {
                  if (_isPlaying) {
                    setState(() {
                      EditAudioPlayer.pause();
                    });
                  } else {
                    setState(() {
                      if (Platform.isAndroid == true) {
                        EditAudioPlayer.play(DeviceFileSource(ref.watch(EditSongProvider).path!));
                      } else {
                        EditAudioPlayer.play(UrlSource(ref.watch(EditSongProvider).path!));
                      }
                    });
                  }
                  _isPlaying = !_isPlaying;
                },
                icon: Icon(
                  _isPlaying ? Icons.pause_outlined : Icons.play_arrow_outlined,
                ),
              ),

              // 10秒戻るボタン
              IconButton(
                onPressed: () {
                  Duration tmp = ref.watch(EditPosiProvider) - const Duration(seconds: 10);
                  // 10秒戻して再生時間がマイナスにならないかチェック
                  if (tmp.inMilliseconds > 0) {
                    EditAudioPlayer.seek(tmp);
                  } else {
                    EditAudioPlayer.seek(Duration.zero);
                  }

                  // 再生終了後でも動くように
                  if (Platform.isAndroid == true) {
                    EditAudioPlayer.play(DeviceFileSource(ref.watch(EditSongProvider).path!));
                  } else {
                    EditAudioPlayer.play(UrlSource(ref.watch(EditSongProvider).path!));
                  }
                },
                icon: const Icon(
                  Icons.fast_rewind_outlined,
                ),
              ),

              // 10秒進むボタン
              IconButton(
                onPressed: () {
                  // 10秒進めて再生時間が曲時間を超えないかチェック
                  Duration tmp = ref.watch(EditPosiProvider) + const Duration(seconds: 10);
                  if (tmp.inMilliseconds < _duration!) {
                    EditAudioPlayer.seek(tmp);
                  } else {
                    // 超えてたら再生時間を最大にして曲を止める
                    EditAudioPlayer.seek(Duration(milliseconds: _duration!));
                    EditAudioPlayer.pause();
                    _isPlaying = false;
                  }
                },
                icon: const Icon(
                  Icons.fast_forward_outlined,
                ),
              ),

              // 再生時間のテキスト
              Text(MilliToMS(ref.watch(EditPosiProvider).inMilliseconds)),
            ],
          ),

          // バナー広告
          const SizedBox(height: 5),
          Container(
            color: Colors.white,
            height: myBanner.size.height.toDouble(),
            width: myBanner.size.width.toDouble(),
            child: AdWidget(ad: myBanner),
          ),
        ],
      ),
    );
  }
}

String MilliToMS(int milliSeconds) {
  String result;
  String minutesDisp;
  String secondsDisp;
  String centiSecondsDisp;

  // 分の取り出し
  int minutes = (milliSeconds / (1000 * 60)).floor();
  if (minutes < 10) {
    minutesDisp = "0$minutes";
  } else {
    minutesDisp = "$minutes";
  }

  // 秒の取り出し
  int seconds = ((milliSeconds / 1000) % 60).floor();
  if (seconds < 10) {
    secondsDisp = "0$seconds";
  } else {
    secondsDisp = "$seconds";
  }

  // センチ秒の取り出し
  int centiSeconds = ((milliSeconds / 10) % 100).floor();
  if (centiSeconds < 10) {
    centiSecondsDisp = "0$centiSeconds";
  } else {
    centiSecondsDisp = "$centiSeconds";
  }

  result = "$minutesDisp:$secondsDisp.$centiSecondsDisp";

  return result;
}
