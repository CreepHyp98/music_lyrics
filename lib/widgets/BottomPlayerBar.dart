import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    ref.watch(EditAPProvider).onPositionChanged.listen((position) {
      // このmountedがないとエラーになる
      if (mounted) {
        ref.read(EditPosiProvider.notifier).state = position;
      }
    });
  }

  // 再生中か停止中か取得
  void listenToEvent() {
    ref.watch(APProvider).onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        if (mounted) {
          setState(() {
            _isPlaying = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 再生状況の取得
    listenToSongStream();
    listenToEvent();

    return BottomAppBar(
      // 画面スクロールで色が変わるのを防ぐ
      elevation: 0,
      height: deviceHeight * 0.15,
      child: Column(
        children: [
          // SliderThemeでスライダーをラップ
          SliderTheme(
            // 上下のパディングをなくす
            data: SliderThemeData(overlayShape: SliderComponentShape.noOverlay),

            child: Slider(
              value: ref.watch(EditPosiProvider).inMilliseconds.toDouble(),
              max: _duration!.toDouble(),
              onChanged: (value) {
                ref.watch(EditAPProvider).seek(Duration(milliseconds: value.toInt()));
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
                      ref.watch(EditAPProvider).pause();
                    });
                  } else {
                    setState(() {
                      ref.watch(EditAPProvider).play(DeviceFileSource(ref.watch(EditSongProvider).path!));
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
                    ref.watch(EditAPProvider).seek(tmp);
                  } else {
                    ref.watch(EditAPProvider).seek(Duration.zero);
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
                    ref.watch(EditAPProvider).seek(tmp);
                  } else {
                    // 超えてたら曲を止める
                    _isPlaying = false;
                    ref.watch(EditAPProvider).pause();
                  }
                },
                icon: const Icon(
                  Icons.fast_forward_outlined,
                ),
              ),

              // 再生時間のテキスト
              Text(MilliToMS(ref.watch(EditPosiProvider).inMilliseconds)),
            ],
          )
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
