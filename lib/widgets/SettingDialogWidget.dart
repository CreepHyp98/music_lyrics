import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/provider/provider.dart';

class SettingDialog extends ConsumerWidget {
  final String? defaultFurigana;
  const SettingDialog({super.key, this.defaultFurigana});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // フリガナ保存用のタイトルキー
    final String titleKey = ref.watch(EditSongProvider).title!;
    // TextFieldの入力text
    final furiganaController = TextEditingController(text: defaultFurigana);

    return AlertDialog(
      content: SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // タイトル（左寄せ）
            SizedBox(
              width: double.infinity,
              child: Text(
                titleKey,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.left,
                maxLines: 1,
              ),
            ),

            // 歌詞データの編集
            GestureDetector(
              child: const Text(
                '歌詞データの編集',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  letterSpacing: 2.0,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.blue,
                ),
              ),
              onTap: () {
                // 編集する曲を取得
                String filePath = ref.watch(EditSongProvider).path!;
                // パスを使ってプレイヤーにセット
                ref.watch(EditAPProvider).setFilePath(filePath);
                // 歌詞編集のテキストフィールドに対象の歌詞をセット
                tec = TextEditingController(text: ref.watch(EditLrcProvider).join('\n'));

                // 再生中なら止める
                if (ref.watch(AudioProvider).audioPlayer != null) {
                  ref.watch(AudioProvider).audioPlayer!.pause();
                }

                // 編集画面に遷移
                Navigator.pushNamed(context, '/edit');
              },
            ),

            // 曲のフリガナTextField
            TextField(
              controller: furiganaController,
              decoration: const InputDecoration(
                labelText: '曲のフリガナ',
                // ラベルテキストを常に浮かす
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),

            // 閉じるボタン
            ElevatedButton(
              onPressed: () async {
                // 入力されたフリガナの保存
                prefs.setString(titleKey, furiganaController.text);
                // ダイアログを閉じる
                Navigator.pop(context);
              },
              child: const Text('閉じる'),
            ),
          ],
        ),
      ),
    );
  }
}
