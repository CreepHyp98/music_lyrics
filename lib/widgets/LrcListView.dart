import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/widgets/LyricWidget.dart';

import 'BottomPlayerBar.dart';

class LrcListView extends ConsumerWidget {
  const LrcListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: deviceWidth * 0.9,
      child: ListView.separated(
        itemCount: ref.watch(EditLrcProvider).length,
        itemBuilder: (context, index) {
          return ListTile(
            // ListTileの設定
            shape: RoundedRectangleBorder(
              side: const BorderSide(),
              borderRadius: BorderRadius.circular(5.0),
            ),
            // leadingとtitleの幅
            horizontalTitleGap: 5,
            // ListTile両端の余白
            contentPadding: const EdgeInsets.symmetric(horizontal: 5),

            // 左側タップで歌いだし時間の取得
            leading: FloatingActionButton(
              key: index == 0 ? key[4] : null,
              heroTag: 'btn$index',
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(
                    Icons.timer_outlined,
                  ),
                  Text(
                    // 時間情報があればその歌いだし時間を表示、なければ空欄
                    checkStartTime(ref.watch(EditLrcProvider)[index]) ? ref.watch(EditLrcProvider)[index].substring(1, 9) : '',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              onPressed: () {
                // 歌いだし時間をタップした時間に更新
                String newTime = MilliToMS(ref.watch(EditPosiProvider).inMilliseconds);
                // すでに時間情報があれば書き換え、なければ
                if (checkStartTime(ref.watch(EditLrcProvider)[index]) == true) {
                  ref.read(EditLrcProvider.notifier).state[index] = ref.watch(EditLrcProvider)[index].replaceRange(1, 9, newTime);
                } else {
                  ref.read(EditLrcProvider.notifier).state[index] = "[$newTime]${ref.watch(EditLrcProvider)[index]}";
                }
              },
            ),

            // 中央タップでダイアログ表示
            title: GestureDetector(
              child: SizedBox(
                height: 48.0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    // 時間情報があれば10文字目から切り出す、なければそのまま
                    checkStartTime(ref.watch(EditLrcProvider)[index]) ? ref.watch(EditLrcProvider)[index].substring(10) : ref.watch(EditLrcProvider)[index],
                    maxLines: 2,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
              // TODO: 保存してもListViewの文字列が更新されない
              //onTap: () {
              //  // ダイアログ表示
              //  showDialog(
              //    context: context,
              //    builder: (context) => LrcDialog(
              //      index: index,
              //    ),
              //  );
              //},
            ),

            // 右タップでそこから再生
            trailing: IconButton(
              // 時間情報がなければグレーアウト
              icon: checkStartTime(ref.watch(EditLrcProvider)[index])
                  ? const Icon(Icons.play_arrow)
                  : const Icon(
                      Icons.play_arrow,
                      color: Colors.grey,
                    ),
              // 時間情報がなければタップ無効
              onPressed: checkStartTime(ref.watch(EditLrcProvider)[index])
                  ? () {
                      // LyricWidgetと同じ関数で時間情報を取得
                      int value = getLyricStartTime(ref.watch(EditLrcProvider)[index]);
                      EditAudioPlayer.seek(Duration(milliseconds: value));
                      ref.read(EditPosiProvider.notifier).state = Duration(milliseconds: value);
                    }
                  : null,
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(
            height: 10.0,
          );
        },
      ),
    );
  }
}

// 時間情報を持ってるかチェックする
bool checkStartTime(String lineLyric) {
  // .lrcの時間情報[mm:ss.xx]から分・秒・センチ秒のインデックスを取得
  int minuteIndex = lineLyric.indexOf(':');
  int secondIndex = lineLyric.indexOf('.');
  int centiSecondIndex = lineLyric.indexOf(']');

  // 時間情報のインデックスが既定の位置にある？
  if ((minuteIndex == 3) && (secondIndex == 6) && (centiSecondIndex == 9)) {
    return true;
  } else {
    return false;
  }
}
