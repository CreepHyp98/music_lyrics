import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/provider/provider.dart';

class SettingDialog extends ConsumerWidget {
  final String? defaultFurigana;
  const SettingDialog({super.key, this.defaultFurigana});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // フリガナ保存用のタイトルキー
    final String titleKey = ref.watch(EditSMProvider).title;
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
              child: Text(
                '歌詞データの編集',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                  letterSpacing: 2.0,
                  decoration: TextDecoration.underline,
                  decorationColor: Theme.of(context).primaryColor,
                ),
              ),
              onTap: () {
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
              // TextFieldに最初からフォーカスをあてる
              autofocus: true,
            ),

            // 保存ボタン
            ElevatedButton(
              onPressed: () async {
                // 入力されたフリガナの保存
                prefs.setString(titleKey, furiganaController.text);
                // ダイアログを閉じる
                Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
