import 'package:flutter/material.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/widgets/bottom_player_bar.dart';

class LrcDialog extends StatelessWidget {
  final int index;
  const LrcDialog({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    // 歌詞テキストのコントローラー
    final lrcController = TextEditingController(text: editLrc[index]);
    // カーソルの位置を末尾に設定
    lrcController.selection = TextSelection.fromPosition(TextPosition(offset: lrcController.text.length));

    // 歌い出し時間のコントローラー
    final timeController = TextEditingController(text: milliToMinSec(editStartTime[index]));

    final myFocusNode = FocusNode();

    return AlertDialog(
      content: SizedBox(
        height: (editStartTime[index] != -1) ? 200 : 120,
        child: Column(
          children: [
            // 歌い出し時間（未設定なら空欄）)
            editStartTime[index] != -1
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ーボタン
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          minimumSize: const Size(40, 40),
                        ),
                        child: const Text('ー'),
                        onPressed: () {
                          // テキストフィールドにフォーカスを移動
                          FocusScope.of(context).requestFocus(myFocusNode);

                          // ミリ秒intに変換
                          int tempMilli = minsecToMilli(timeController.text);

                          // -100ミリしてコントローラーに入れる
                          if (tempMilli - 100 > 0) {
                            timeController.text = milliToMinSec(tempMilli - 100);
                          }
                        },
                      ),

                      // テキストフィールド
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 90,
                        child: TextField(
                          focusNode: myFocusNode,
                          controller: timeController,
                          style: const TextStyle(fontSize: 15),
                          decoration: const InputDecoration(
                            labelText: '時間',
                            // ラベルテキストを常に浮かす
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),

                      // ＋ボタン
                      const SizedBox(width: 10),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          minimumSize: const Size(40, 40),
                        ),
                        child: const Text('＋'),
                        onPressed: () {
                          // テキストフィールドにフォーカスを移動
                          FocusScope.of(context).requestFocus(myFocusNode);

                          // ミリ秒intに変換
                          int tempMilli = minsecToMilli(timeController.text);

                          // +100ミリしてコントローラーに入れる
                          timeController.text = milliToMinSec(tempMilli + 100);
                        },
                      ),
                    ],
                  )
                : Container(),

            const Spacer(),
            // 歌詞のTextField
            SizedBox(
              width: deviceWidth - 100,
              child: TextField(
                controller: lrcController,
                style: const TextStyle(fontSize: 15),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'テキスト',
                  // ラベルテキストを常に浮かす
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // キャンセル
            GestureDetector(
              onTap: () {
                // ダイアログを閉じる
                Navigator.pop(context);
              },
              child: const Text(
                'キャンセル',
                style: TextStyle(fontSize: 15),
              ),
            ),

            // 完了
            GestureDetector(
              onTap: () {
                // 歌詞テキストの更新
                editLrc[index] = lrcController.text;

                // 歌い出し時間の更新
                if (editStartTime[index] != -1) {
                  editStartTime[index] = minsecToMilli(timeController.text);
                }

                // ダイアログを閉じる
                Navigator.pop(context);
              },
              child: Text(
                '完了',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// mm:ss:cc → ミリ秒のint
int minsecToMilli(String startTime) {
  // 分・秒・センチ秒をintで取得
  int minutes = int.parse(startTime.substring(0, 2));
  int seconds = int.parse(startTime.substring(3, 5));
  int centiSeconds = int.parse(startTime.substring(6, 8));

  // それらをミリ秒に変換
  int milliSeconds = (minutes * 60000) + (seconds * 1000) + (centiSeconds * 10);
  return milliSeconds;
}
