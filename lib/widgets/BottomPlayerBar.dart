import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/provider/provider.dart';

class BottomPlayerBar extends ConsumerStatefulWidget {
  const BottomPlayerBar({super.key});

  @override
  ConsumerState<BottomPlayerBar> createState() => _BottomPlayerBarState();
}

class _BottomPlayerBarState extends ConsumerState<BottomPlayerBar> {
  Duration _duration = const Duration();
  bool _isPlaying = false;

  void listenToSongStream2() {
    // 音源ファイルの曲時間を取得
    ref.watch(EditAPProvider).durationStream.listen((duration) {
      if (duration != null) {
        _duration = duration;
      }
    });

    // 現在の再生位置を取得
    ref.watch(EditAPProvider).positionStream.listen((position) {
      // このmountedがないとエラーになる
      if (mounted) {
        ref.read(EditPosiProvider.notifier).state = position;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 再生位置などの取得
    listenToSongStream2();

    return BottomAppBar(
      height: deviceHeight * 0.2,
      child: Column(
        children: [
          // スライダー
          Slider(
            //min: Duration.zero.inMilliseconds.toDouble(),
            value: ref.watch(EditPosiProvider).inMilliseconds.toDouble(),
            max: _duration.inMilliseconds.toDouble(),
            onChanged: (value) {
              ref.watch(EditAPProvider).seek(Duration(milliseconds: value.toInt()));
            },
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
                      ref.watch(EditAPProvider).play();
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
                  if (tmp < _duration) {
                    ref.watch(EditAPProvider).seek(tmp);
                  } else {
                    // 超えてたら再生時間を0に戻して曲を止める
                    ref.watch(EditAPProvider).seek(Duration.zero);
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
