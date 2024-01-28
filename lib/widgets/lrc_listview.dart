import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/widgets/lyric_text.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'bottom_player_bar.dart';

class LrcListView extends ConsumerStatefulWidget {
  const LrcListView({super.key});

  @override
  ConsumerState<LrcListView> createState() => _LrcListViewState();
}

class _LrcListViewState extends ConsumerState<LrcListView> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  int endIndex = 6;

  @override
  void initState() {
    super.initState();

    // 画面に表示されているリストの末尾のインデックス
    _itemPositionsListener.itemPositions.addListener(() {
      final positions = _itemPositionsListener.itemPositions.value;
      if (positions.isNotEmpty) {
        endIndex = positions.last.index;
      }
    });
  }

  Future<void> updateStartTime(int index) async {
    // 歌いだし時間をタップした時間に更新
    String newTime = milliToMinSec(ref.watch(editPosiProvider).inMilliseconds);
    // すでに時間情報があれば書き換え、なければlrcの形式にして追加
    if (getLyricStartTime(editLrc[index]) != -1) {
      editLrc[index] = editLrc[index].replaceRange(1, 9, newTime);
    } else {
      editLrc[index] = "[$newTime]${editLrc[index]}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: deviceWidth * 0.9,
      child: ScrollablePositionedList.separated(
        itemScrollController: _itemScrollController,
        itemPositionsListener: _itemPositionsListener,
        itemCount: editLrc.length,
        itemBuilder: (context, index) {
          return ListTile(
            // ListTileの設定
            shape: RoundedRectangleBorder(
              side: const BorderSide(),
              borderRadius: BorderRadius.circular(5.0),
            ),
            // leadingとtitleの幅
            horizontalTitleGap: 0,
            // ListTile内の両端の余白
            contentPadding: const EdgeInsets.symmetric(horizontal: 5),

            // 左側タップで歌いだし時間の取得
            leading: FloatingActionButton(
              key: index == 0 ? key[4] : null,
              heroTag: 'btn$index',
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(Icons.timer_outlined),
                  Text(
                    // 時間情報があればその歌いだし時間を表示、なければ空欄
                    (getLyricStartTime(editLrc[index]) != -1) ? editLrc[index].substring(1, 9) : '',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              onPressed: () async {
                // 歌い出し時間をタップした時間に更新
                updateStartTime(index);
                // タップされたインデックスが画面の一番下なら自動スクロールする
                if (index == endIndex) {
                  _itemScrollController.scrollTo(
                    index: index - 6,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutQuart,
                  );
                }
              },
            ),

            // 中央タップでダイアログ表示
            title: GestureDetector(
              child: SizedBox(
                height: 47.0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 7.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      // 時間情報があれば10文字目から切り出す、なければそのまま
                      (getLyricStartTime(editLrc[index]) != -1) ? editLrc[index].substring(10) : editLrc[index],
                      maxLines: 2,
                      style: const TextStyle(fontSize: 15),
                    ),
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
                icon: (getLyricStartTime(editLrc[index]) != -1)
                    ? const Icon(Icons.play_arrow)
                    : const Icon(
                        Icons.play_arrow,
                        color: Colors.grey,
                      ),
                // 時間情報がなければタップ無効
                onPressed: (getLyricStartTime(editLrc[index]) != -1)
                    ? () {
                        // LyricWidgetと同じ関数で時間情報を取得
                        int value = getLyricStartTime(editLrc[index]);
                        editAudioPlayer.seek(Duration(milliseconds: value));
                        ref.read(editPosiProvider.notifier).state = Duration(milliseconds: value);
                      }
                    : null),
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
