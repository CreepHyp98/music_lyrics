import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/widgets/vertical_rotated_writing.dart';
import 'package:wakelock/wakelock.dart';

class LyricText extends ConsumerStatefulWidget {
  const LyricText({super.key});

  @override
  ConsumerState<LyricText> createState() => _LyricTextState();
}

class _LyricTextState extends ConsumerState<LyricText> {
  final ScrollController _scrollController = ScrollController();
  // 一行ごとに分割された歌詞Listのインデックス
  late int currentLyricIndex;
  // 再生時間（ミリ秒）を保持
  late int currentMilliSeconds;
  // 歌詞テキストのリスト
  late List<String> lyricList;
  // 歌いだし時間のリスト
  late List<int> startTime;
  // 自動スクロール移動ピクセル数
  late double offset;
  // リストへの代入したか
  bool _done = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void assignLyricStartTime() {
    // 各変数やリストを初期化
    currentLyricIndex = 0;
    currentMilliSeconds = 0;
    offset = 0;
    // 一行目が画面の中央に来るように改行を入れとく
    lyricList = ['\n', '\n'];
    // 改行の追加に合わせて時間情報を入れとく
    startTime = [0, 1];

    // 作業用変数に歌詞プロバイダーをセット
    List<String> temp = ref.watch(lyricProvider);
    // 歌詞プロバイダーから歌い出し時間と歌詞をリストに追加
    for (int i = 0; i < temp.length; i++) {
      startTime.add(getLyricStartTime(temp[i]));
      // すでにstartTimeには[0, 1]が入っているので+2する
      if (startTime[i + 2] != -1) {
        lyricList.add(temp[i].substring(10));
      } else {
        lyricList.add(temp[i]);
      }
    }
    // 最終行が画面の中央に来るように改行を入れとく
    lyricList.addAll(List.generate(5, (index) => '\n'));
    // 歌い出し時間には最後の歌いだし時間+3分の値を入れとく
    startTime.addAll(List.generate(5, (index) => getLyricStartTime(temp.last) + 180000));

    // 代入が完了したのでスクロール位置を先頭に戻して、画面を再描画
    setState(() {
      _done = true;
    });
  }

  void syncLyric() {
    int nextTime = 0;

    // 保持している値が実際の再生時間を超える ⇒ 曲が変わった
    if (currentMilliSeconds > ref.watch(positionProvider).inMilliseconds) {
      // 歌詞リストを更新
      _done = false;
      assignLyricStartTime();
      // スクロール位置を先頭に戻す
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeOutQuart);
    }
    // 再生時間を更新
    currentMilliSeconds = ref.watch(positionProvider).inMilliseconds;

    if (startTime[currentLyricIndex] >= 0) {
      // 歌詞同期時、かつ再生中は自動スリープを無効にする
      Wakelock.enable();
      try {
        // 最後のインデックスではないなら
        if (currentLyricIndex != lyricList.length - 1) {
          // 次の歌詞の歌いだし時間を取得
          nextTime = startTime[currentLyricIndex + 1];
          // 現在の再生時間がそれを超えたなら
          if (currentMilliSeconds >= nextTime) {
            if (currentLyricIndex == 1) {
              // 一行目だけは固定幅で動かす
              offset = 10;
            } else if (currentLyricIndex > 1) {
              // 現在の行数分ずらす
              offset = offset + ((1 + (lyricList[currentLyricIndex].length ~/ 30)) * 34.8);
            }
            _scrollController.animateTo(
              offset,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutQuart,
            );

            // 歌詞Listのインデックスを次に進める
            currentLyricIndex++;
          }
        }
      } catch (e) {
        // まだlyricProviderに値が入ってない
      }
    } else {
      // .lrcファイルがない、もしくは.lrcファイルはあるが時間情報がない
      // 歌詞同期はないので自動スリープを有効にする
      Wakelock.disable();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done == false) {
      assignLyricStartTime();
    }

    syncLyric();

    return ListView.builder(
      controller: _scrollController,
      itemCount: lyricList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          child: VerticalRotatedWriting(
            // 同期されていない空行を無視しないために空白チェック
            text: (lyricList[index] != '') ? lyricList[index] : '\n',
            fontSize: 18,
            // 現在の歌詞インデックスもしくは歌い出し時間がなければ黒色、それ以外は灰色
            color: ((index == currentLyricIndex) || (startTime[index] == -1)) ? Colors.black : Colors.grey,
          ),
          onTap: () {
            // 歌い出し時間が設定されている場合のみ飛べるようにする
            if (startTime[index] != -1) {
              // スクロール位置を更新（先頭二行の分、for文は2からスタート）
              offset = 10;
              for (int i = 2; i < index; i++) {
                offset = offset + ((1 + (lyricList[i].length ~/ 30)) * 34.8);
              }
              _scrollController.animateTo(
                offset,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutQuart,
              );

              // タップしたインデックスに更新
              currentLyricIndex = index;
              // その歌い出し時間に移動
              audioPlayer.seek(Duration(milliseconds: startTime[currentLyricIndex]));
              // positionProviderの更新がかみ合わず、スクロール位置が先頭に戻ってしまうことがあるので0をセット
              currentMilliSeconds = 0;
            }
          },
        );
      },
      // 右から左にスクロール
      reverse: true,
      // 水平方向にスクロール
      scrollDirection: Axis.horizontal,
    );
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
