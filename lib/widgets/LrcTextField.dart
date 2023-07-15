import 'package:flutter/material.dart';
import 'package:music_lyrics/provider/provider.dart';

class LrcTextField extends StatelessWidget {
  final String? data;
  const LrcTextField({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: deviceWidth * 0.9,
      child: TextField(
        controller: TextEditingController(text: data),
        scrollController: ScrollController(),
        maxLines: 20,
        decoration: const InputDecoration(
          labelText: '歌詞データ',
          // ラベルテキストを常に浮かす
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(),
        ),
        // TextFieldに最初はフォーカスをあてない
        autofocus: false,
      ),
    );
  }
}
