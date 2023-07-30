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
    return SizedBox(
      width: deviceWidth * 0.9,
      child: TextField(
        controller: tec,
        scrollController: ScrollController(),
        maxLines: 22,
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
