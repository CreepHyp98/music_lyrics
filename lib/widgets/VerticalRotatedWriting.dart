import 'package:flutter/material.dart';

class VerticalRotatedWriting extends StatelessWidget {
  final String text;
  final double size;

  const VerticalRotatedWriting({
    required this.text,
    required this.size,
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
              _character(rune),
            ],
          )
      ],
    );
  }

  // アルファベットを垂直方向に揃えるためSizedBoxでwrap
  Widget _character(String char) {
    // フォントサイズからテキストボックスサイズを指定（縦横同じ）
    double boxSize = size * 1.1;

    if (VerticalRotatedSymbols.map[char] != null) {
      return SizedBox(
        width: boxSize,
        height: boxSize,
        child: Center(
          child: Text(
            VerticalRotatedSymbols.map[char]!,
            style: TextStyle(
              fontSize: size,
              fontFamily: 'shippori3',
              height: 1.0,
            ),
          ),
        ),
      );
    } else if (checkSmallScript(char) == true) {
      // 小書き文字なら
      return Container(
        // 右寄せするため左に余白を入れる
        padding: const EdgeInsets.only(left: 3.0),
        width: boxSize,
        // 上寄せする分高さは少し小さくする
        height: boxSize * 0.9,
        child: Text(
          char,
          style: TextStyle(
            fontSize: size,
            fontFamily: 'shippori3',
            // 上寄せするため1よりも小さい値を設定
            height: 0.7,
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
              fontSize: size,
              fontFamily: 'shippori3',
              height: 1.0,
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

  for (int i = 0; i < checkList.length; i++) {
    if (char == checkList[i]) {
      return true;
    }
  }
  return false;
}
