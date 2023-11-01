import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/provider/provider.dart';

class ColorDialog extends ConsumerWidget {
  const ColorDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int currentColor = ref.watch(ColorValueProvider);

    return AlertDialog(
      content: BlockPicker(
        pickerColor: Color(currentColor),
        onColorChanged: (Color color) {
          // 選択されたカラーを保存
          currentColor = color.value;
          prefs.setInt('selectedColor', currentColor);
          ref.read(ColorValueProvider.notifier).state = currentColor;
        },

        // 想定した色にならなかったためデフォルトから黒色系統削除
        availableColors: const [
          Colors.red,
          Colors.pink,
          Colors.purple,
          Colors.deepPurple,
          Colors.indigo,
          Colors.blue,
          Colors.lightBlue,
          Colors.cyan,
          Colors.teal,
          Colors.green,
          Colors.lightGreen,
          Colors.yellow,
          Colors.amber,
          Colors.orange,
          Colors.deepOrange,
        ],

        layoutBuilder: (BuildContext context, List<Color> colors, PickerItem child) {
          Orientation orientation = MediaQuery.of(context).orientation;

          return SizedBox(
            width: 300,
            // 色削除に合わせて高さもデフォルトから変更
            height: 270,
            child: GridView.count(
              crossAxisCount: orientation == Orientation.portrait ? 4 : 6,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              children: [for (Color color in colors) child(color)],
            ),
          );
        },
      ),
      actions: [
        GestureDetector(
          onTap: () {
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
