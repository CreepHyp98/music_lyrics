import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/class/song_database.dart';
import 'package:music_lyrics/widgets/delete_dialog.dart';

class SongInfoDialog extends ConsumerWidget {
  const SongInfoDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TextFieldの入力text
    final furiController = TextEditingController(text: ref.watch(editSongProvider).titleFuri);
    // カーソルの位置を末尾に設定
    furiController.selection = TextSelection.fromPosition(TextPosition(offset: furiController.text.length));

    return AlertDialog(
      // タイトル（左寄せ）
      title: Text(
        ref.watch(editSongProvider).title!,
        style: const TextStyle(fontSize: 20),
        textAlign: TextAlign.left,
        maxLines: 1,
      ),
      content: SizedBox(
        height: 160,
        child: Column(
          children: [
            // 曲のフリガナTextField
            TextField(
              controller: furiController,
              decoration: const InputDecoration(
                labelText: '曲のフリガナ',
                // ラベルテキストを常に浮かす
                floatingLabelBehavior: FloatingLabelBehavior.always,
                // 入力文字と下線の隙間を埋める
                contentPadding: EdgeInsets.zero,
              ),
            ),

            // 歌詞データの編集
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.edit_note),
              title: const Text(
                '歌詞データの編集',
              ),
              onTap: (() {
                // 歌詞編集のテキストフィールドに対象の歌詞をセット
                tec = TextEditingController(text: ref.watch(editLrcProvider).join('\n'));

                // 再生中なら止める
                audioPlayer.pause();

                // 編集画面に遷移
                Navigator.pushNamed(context, '/edit');
              }),
            ),

            // ライブラリから削除
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.delete),
              title: const Text(
                'ライブラリから削除',
              ),
              onTap: (() {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => const DeleteDialog(),
                );
              }),
            ),
          ],
        ),
      ),

      actions: [
        // 閉じる
        GestureDetector(
          onTap: () {
            // 入力されたフリガナの保存編集用プロバイダーにセット
            ref.read(editSongProvider.notifier).state.titleFuri = furiController.text;
            // データベースを更新
            SongDB.instance.updateSong(ref.watch(editSongProvider));

            // ダイアログを閉じる
            Navigator.pop(context);
          },
          child: const Text(
            '閉じる',
            style: TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }
}
