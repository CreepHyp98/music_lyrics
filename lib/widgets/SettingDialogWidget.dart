import 'package:flutter/material.dart';
import 'package:music_lyrics/provider/provider.dart';

class furiganaSettingDialog extends StatelessWidget {
  final String titleKey;
  final String? defaultFurigana;
  const furiganaSettingDialog({super.key, required this.titleKey, this.defaultFurigana});

  @override
  Widget build(BuildContext context) {
    // TextFieldの入力text
    final furiganaController = TextEditingController(text: defaultFurigana);

    return AlertDialog(
      content: SizedBox(
        height: 150,
        child: Column(
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
