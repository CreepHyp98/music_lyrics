import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/widgets/lrc_dialog.dart';
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
            leading: GestureDetector(
              key: index == 0 ? key[4] : null,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                    Text(
                      // 歌い出し時間があれば表示
                      (editStartTime[index] != -1) ? milliToMinSec(editStartTime[index]) : '',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              onTap: () {
                // 歌いだし時間をタップした時間に更新(タップの誤差があるので100ミリ秒引いとく)
                editStartTime[index] = ref.watch(editPosiProvider).inMilliseconds - 100;

                if (index > 0) {
                  // 一個前の歌い出し時間が空で空行なら
                  if ((editStartTime[index - 1] == -1) && (editLrc[index - 1] == '')) {
                    // 今の歌い出し時間の-0.5秒をセット
                    editStartTime[index - 1] = editStartTime[index] - 500;
                  }
                }

                // タップされたインデックスが画面の一番下なら自動スクロールする
                if ((index == endIndex) && (index != editLrc.length - 1)) {
                  _itemScrollController.scrollTo(
                    // 次のインデックスが空行なら二行スクロール
                    index: editLrc[index + 1] != '' ? index - 6 : index - 5,
                    duration: const Duration(milliseconds: 500),
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
                      editLrc[index],
                      maxLines: 2,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ),
              onTap: () {
                // ダイアログ表示
                showDialog(
                  context: context,
                  builder: (context) => LrcDialog(
                    index: index,
                  ),
                );
              },
            ),

            // 右タップでそこから再生
            trailing: IconButton(
                // 時間情報がなければグレーアウト
                icon: (editStartTime[index] != -1)
                    ? const Icon(Icons.play_arrow)
                    : const Icon(
                        Icons.play_arrow,
                        color: Colors.grey,
                      ),
                // 時間情報がなければタップ無効
                onPressed: (editStartTime[index] != -1)
                    ? () {
                        // LyricWidgetと同じ関数で時間情報を取得
                        editAudioPlayer.seek(Duration(milliseconds: editStartTime[index]));
                        ref.read(editPosiProvider.notifier).state = Duration(milliseconds: editStartTime[index]);
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
