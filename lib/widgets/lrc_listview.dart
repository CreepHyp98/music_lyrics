import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/widgets/lyric_text.dart';

import 'bottom_player_bar.dart';

class LrcListView extends ConsumerWidget {
  const LrcListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: deviceWidth * 0.9,
      child: ListView.separated(
        itemCount: ref.watch(editLrcProvider).length,
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
                    (getLyricStartTime(ref.watch(editLrcProvider)[index]) != -1) ? ref.watch(editLrcProvider)[index].substring(1, 9) : '',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              onPressed: () {
                // 歌いだし時間をタップした時間に更新
                String newTime = milliToMinSec(ref.watch(editPosiProvider).inMilliseconds);
                // すでに時間情報があれば書き換え、なければ
                if (getLyricStartTime(ref.watch(editLrcProvider)[index]) != -1) {
                  ref.read(editLrcProvider.notifier).state[index] = ref.watch(editLrcProvider)[index].replaceRange(1, 9, newTime);
                } else {
                  ref.read(editLrcProvider.notifier).state[index] = "[$newTime]${ref.watch(editLrcProvider)[index]}";
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
                    (getLyricStartTime(ref.watch(editLrcProvider)[index]) != -1) ? ref.watch(editLrcProvider)[index].substring(10) : ref.watch(editLrcProvider)[index],
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
              icon: (getLyricStartTime(ref.watch(editLrcProvider)[index]) != -1)
                  ? const Icon(Icons.play_arrow)
                  : const Icon(
                      Icons.play_arrow,
                      color: Colors.grey,
                    ),
              // 時間情報がなければタップ無効
              onPressed: (getLyricStartTime(ref.watch(editLrcProvider)[index]) != -1)
                  ? () {
                      // LyricWidgetと同じ関数で時間情報を取得
                      int value = getLyricStartTime(ref.watch(editLrcProvider)[index]);
                      editAudioPlayer.seek(Duration(milliseconds: value));
                      ref.read(editPosiProvider.notifier).state = Duration(milliseconds: value);
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
