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
    // フォントサイズからテキストボックスサイズを指定
    double boxWidth = size;
    double boxHeight = size * 1.4375;

    if (VerticalRotatedSymbols.map[char] != null) {
      return SizedBox(
        width: boxWidth,
        height: boxHeight,
        child: Center(
          child: Text(
            VerticalRotatedSymbols.map[char]!,
            style: TextStyle(fontSize: size, fontFamily: 'shippori3'),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: boxWidth,
        height: boxHeight,
        child: Center(
          child: Text(
            char,
            style: TextStyle(fontSize: size, fontFamily: 'shippori3'),
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
    '─': '丨',
    '-': '丨',
    'ｰ': '丨',
    //'↑': '→',
    //'↓': '←',
    //'←': '↑',
    //'→': '↓',
    //'_': '丨 ',
    //'−': '丨',
    //'－': '丨',
    //'—': '丨',
    //'〜': '丨',
    //'～': '丨',
    //'／': '＼',
    //'…': '︙',
    //'‥': '︰',
    //'︙': '…',
    //'：': '︓',
    //':': '︓',
    //'；': '︔',
    //';': '︔',
    //'＝': '॥',
    //'=': '॥',
    //'（': '︵',
    //'(': '︵',
    //'）': '︶',
    //')': '︶',
    //'［': '﹇',
    //"[": '﹇',
    //'］': '﹈',
    //']': '﹈',
    //'｛': '︷',
    //'{': '︷',
    //'＜': '︿',
    //'<': '︿',
    //'＞': '﹀',
    //'>': '﹀',
    //'｝': '︸',
    //'}': '︸',
    //'「': '﹁',
    //'」': '﹂',
    //'『': '﹃',
    //'』': '﹄',
    //'【': '︻',
    //'】': '︼',
    //'〖': '︗',
    //'〗': '︘',
    //'｢': '﹁',
    //'｣': '﹂',
    //',': '︐',
    //'､': '︑',
  };
}
