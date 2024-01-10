import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/widgets/vertical_rotated_writing.dart';
import 'package:wakelock/wakelock.dart';

class LyricWidget extends ConsumerStatefulWidget {
  const LyricWidget({super.key});

  @override
  ConsumerState<LyricWidget> createState() => _LyricWidgetState();
}

class _LyricWidgetState extends ConsumerState<LyricWidget> {
  // 一行ごとの歌詞list
  List<String> lineLyric = [];
  // 一行ごとに分割された歌詞Listのインデックス
  int currentLyricIndex = 0;
  // 再生時間（ミリ秒）を保持
  int currentMilliSeconds = 0;

  String syncLyric() {
    String currentLyric = '';
    int startTime, nextTime = 0;

    // 保持している値が実際の再生時間を超える ⇒ 曲が変わった
    if (currentMilliSeconds > ref.watch(positionProvider).inMilliseconds) {
      // 歌詞Listのインデックスを初期化
      currentLyricIndex = 0;
    }
    // 再生時間を更新
    currentMilliSeconds = ref.watch(positionProvider).inMilliseconds;
    // 歌詞データから歌いだし時間を取得
    startTime = getLyricStartTime(ref.watch(lyricProvider)[currentLyricIndex]);

    if (startTime >= 0) {
      // 歌詞同期時は自動スリープを無効にする
      Wakelock.enable();
      try {
        // 最後のインデックスではないなら
        if (currentLyricIndex != ref.watch(lyricProvider).length - 1) {
          // 次の歌詞の歌いだし時間を取得
          nextTime = getLyricStartTime(ref.watch(lyricProvider)[currentLyricIndex + 1]);
          // 現在の再生時間がそれを超えたなら
          if (currentMilliSeconds >= nextTime) {
            // 歌詞Listのインデックスを次に進める
            currentLyricIndex++;
          }
        }

        if (currentMilliSeconds >= startTime) {
          currentLyric = ref.watch(lyricProvider)[currentLyricIndex].substring(10);
        }
      } catch (e) {
        // まだlyricProviderに値が入ってない
      }
    } else {
      // .lrcファイルがない、もしくは.lrcファイルはあるが時間情報がない
      // 歌詞同期はないので自動スリープを有効にする
      Wakelock.disable();
    }

    return currentLyric;
  }

  @override
  Widget build(BuildContext context) {
    double fontSizeM = 18;

    return VerticalRotatedWriting(text: syncLyric(), size: fontSizeM);
  }
}

int getLyricStartTime(String lineLyric) {
  // .lrcの時間情報[mm:ss.xx]から分・秒・センチ秒のインデックスを取得
  int minuteIndex = lineLyric.indexOf(':');
  int secondIndex = lineLyric.indexOf('.');
  int centiSecondIndex = lineLyric.indexOf(']');

  try {
    // 分・秒・センチ秒をintで取得
    int minutes = int.parse(lineLyric.substring(1, minuteIndex));
    int seconds = int.parse(lineLyric.substring(minuteIndex + 1, secondIndex));
    int centiSeconds = int.parse(lineLyric.substring(secondIndex + 1, centiSecondIndex));

    // それらをミリ秒に変換
    int milliSeconds = (minutes * 60000) + (seconds * 1000) + (centiSeconds * 10);
    return milliSeconds;
  } catch (e) {
    // .lrcファイルがない、もしくは.lrcファイルはあるが時間情報がない
    return -1;
  }
}
