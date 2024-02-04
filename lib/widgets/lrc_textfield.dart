import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/provider/provider.dart';

class LrcTextField extends ConsumerStatefulWidget {
  const LrcTextField({super.key});

  @override
  ConsumerState<LrcTextField> createState() => _LrcTextFieldState();
}

class _LrcTextFieldState extends ConsumerState<LrcTextField> {
  @override
  Widget build(BuildContext context) {
    // キーボードが出たときの、画面下端からキーボード上端までの高さ
    final textFieldBottom = MediaQuery.of(context).viewInsets.bottom;

    return SizedBox(
      width: deviceWidth * 0.9,
      height: deviceHeight - textFieldBottom,
      child: TextField(
        controller: tec,
        style: const TextStyle(fontSize: 15),
        maxLines: 50,
        decoration: const InputDecoration(
          labelText: '歌詞データ',
          // ラベルテキストを常に浮かす
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
