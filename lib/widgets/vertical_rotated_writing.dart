import 'package:flutter/material.dart';

class VerticalRotatedWriting extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;

  const VerticalRotatedWriting({
    super.key,
    required this.text,
    required this.fontSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final splitText = text.split('');

    return Wrap(
      textDirection: TextDirection.rtl,
      direction: Axis.vertical,
      children: [
        for (var rune in splitText)
          Row(
            children: [
              const SizedBox(width: 15),
              _character(rune),
            ],
          )
      ],
    );
  }

  // アルファベットを垂直方向に揃えるためSizedBoxでwrap
  Widget _character(String char) {
    // フォントサイズからテキストボックスサイズを指定（縦横同じ）
    double boxSize = fontSize * 1.1;

    if (VerticalRotatedSymbols.map[char] != null) {
      // 記号なら
      return SizedBox(
        width: boxSize,
        height: boxSize,
        child: Center(
          child: Text(
            VerticalRotatedSymbols.map[char]!,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: 'shippori3',
              height: 1.0,
              // 指定があれば色を変える
              color: color,
            ),
          ),
        ),
      );
    } else if (checkSmallScript(char) == true) {
      // 小書き文字なら
      return Container(
        // 右寄せするため左に余白を入れる
        padding: const EdgeInsets.only(left: 4.0),
        width: boxSize,
        height: boxSize,
        child: Text(
          char,
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: 'shippori3',
            // 上寄せするため1よりも小さい値を設定
            height: 0.8,
            // 指定があれば色を変える
            color: color,
          ),
        ),
      );
    } else {
      return SizedBox(
        width: boxSize,
        height: boxSize,
        child: Center(
          child: Text(
            char,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: 'shippori3',
              height: 1.0,
              color: color,
            ),
          ),
        ),
      );
    }
  }
}

class VerticalRotatedSymbols {
  static const map = {
    ' ': '　',
    '。': '︒',
    '、': '︑',
    'ー': '丨',
    '－': '丨',
    '─': '丨',
    'ｰ': '丨',
    '−': '丨',
    '-': '丨',
    '_': '丨 ',
    '「': '﹁',
    '｢': '﹁',
    '」': '﹂',
    '｣': '﹂',
    '『': '﹃',
    '』': '﹄',
    '（': '︵',
    '(': '︵',
    '）': '︶',
    ')': '︶',
    '…': '︙',
    '‥': '︰',
    '＝': '॥',
    '=': '॥',
    '［': '﹇',
    "[": '﹇',
    '］': '﹈',
    ']': '﹈',
    '｛': '︷',
    '{': '︷',
    '｝': '︸',
    '}': '︸',
    '＜': '︿',
    '<': '︿',
    '＞': '﹀',
    '>': '﹀',
    '【': '︻',
    '】': '︼',
    '〖': '︗',
    '〗': '︘',
  };
}

bool checkSmallScript(String char) {
  const List<String> checkList = [
    'ぁ',
    'ぃ',
    'ぅ',
    'ぇ',
    'ぉ',
    'ゕ',
    'っ',
    'ゃ',
    'ゅ',
    'ょ',
    'ァ',
    'ィ',
    'ゥ',
    'ェ',
    'ォ',
    'ヵ',
    'ヶ',
    'ッ',
    'ャ',
    'ュ',
    'ョ',
  ];

  for (String smallScript in checkList) {
    if (char == smallScript) {
      return true;
    }
  }
  return false;
}
