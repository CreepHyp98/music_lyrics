import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/provider/provider.dart';

class ColorDialog extends ConsumerWidget {
  const ColorDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int currentColor = ref.watch(colorValueProvider);

    return AlertDialog(
      content: BlockPicker(
        pickerColor: Color(currentColor),
        onColorChanged: (Color color) {
          currentColor = color.value;
        },
      ),
      actions: [
        GestureDetector(
          onTap: () {
            // 選択されたカラーを保存
            prefs.setInt('selectedColor', currentColor);
            ref.read(colorValueProvider.notifier).state = currentColor;

            Navigator.pop(context);
          },
          child: const Text(
            '保存',
            style: TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }
}

// アクセントカラーが思った色にならないので自作
ColorScheme createColorScheme(int colorValue) {
  ColorScheme result;

  if (colorValue == Colors.red.value) {
    result = const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.red,
      onPrimary: Colors.white,
      secondary: Color(0xFF775652),
      onSecondary: Colors.white,
      error: Color(0xFFba1b1b),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );
  } else if (colorValue == Colors.pink.value) {
    result = const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.pink,
      onPrimary: Colors.white,
      secondary: Color(0xFF76565b),
      onSecondary: Colors.white,
      error: Color(0xFFba1b1b),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );
  } else if (colorValue == Colors.purple.value) {
    result = const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.purple,
      onPrimary: Colors.white,
      secondary: Color(0xFF6b586b),
      onSecondary: Colors.white,
      error: Color(0xFFba1b1b),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );
  } else if (colorValue == Colors.deepPurple.value) {
    result = const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.deepPurple,
      onPrimary: Colors.white,
      secondary: Color(0xFF635b70),
      onSecondary: Colors.white,
      error: Color(0xFFba1b1b),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );
  } else if (colorValue == Colors.indigo.value) {
    result = const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.indigo,
      onPrimary: Colors.white,
      secondary: Color(0xFF5b5d71),
      onSecondary: Colors.white,
      error: Color(0xFFba1b1b),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );
  } else if (colorValue == Colors.blue.value) {
    result = const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.blue,
      onPrimary: Colors.white,
      secondary: Color(0xFF535f70),
      onSecondary: Colors.white,
      error: Color(0xFFba1b1b),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );
  } else if (colorValue == Colors.lightBlue.value) {
    result = ColorScheme(
      brightness: Brightness.light,
      primary: Colors.lightBlue.shade600,
      onPrimary: Colors.white,
      secondary: const Color(0xFF5b5d71),
      onSecondary: Colors.white,
      error: const Color(0xFFba1b1b),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );
  } else if (colorValue == Colors.cyan.value) {
    result = ColorScheme(
      brightness: Brightness.light,
      primary: Colors.cyan.shade600,
      onPrimary: Colors.white,
      secondary: const Color(0xFF4a6267),
      onSecondary: Colors.white,
      error: const Color(0xFFba1b1b),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );
  } else if (colorValue == Colors.teal.value) {
    result = const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.teal,
      onPrimary: Colors.white,
      secondary: Color(0xFF4a635f),
      onSecondary: Colors.white,
      error: Color(0xFFba1b1b),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );
  } else if (colorValue == Colors.green.value) {
    result = const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.green,
      onPrimary: Colors.white,
      secondary: Color(0xFF52634f),
      onSecondary: Colors.white,
      error: Color(0xFFba1b1b),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );
  } else if (colorValue == Colors.lightGreen.value) {
    result = ColorScheme(
      brightness: Brightness.light,
      primary: Colors.lightGreen.shade700,
      onPrimary: Colors.white,
      secondary: const Color(0xFF58624a),
      onSecondary: Colors.white,
      error: const Color(0xFFba1b1b),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );
  } else if (colorValue == Colors.lime.value) {
    result = ColorScheme(
      brightness: Brightness.light,
      primary: Colors.lime.shade700,
      onPrimary: Colors.white,
      secondary: const Color(0xFF5e6044),
      onSecondary: Colors.white,
      error: const Color(0xFFba1b1b),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );
  } else if (colorValue == Colors.yellow.value) {
    result = ColorScheme(
      brightness: Brightness.light,
      primary: Colors.yellow.shade700,
      onPrimary: Colors.white,
      secondary: const Color(0xFF645f41),
      onSecondary: Colors.white,
      error: const Color(0xFFba1b1b),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );
  } else if (colorValue == Colors.amber.value) {
    result = ColorScheme(
      brightness: Brightness.light,
      primary: Colors.amber.shade700,
      onPrimary: Colors.white,
      secondary: const Color(0xFF6b5c3f),
      onSecondary: Colors.white,
      error: const Color(0xFFba1b1b),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );
  } else if (colorValue == Colors.orange.value) {
    result = ColorScheme(
      brightness: Brightness.light,
      primary: Colors.orange.shade700,
      onPrimary: Colors.white,
      secondary: const Color(0xFF735a42),
      onSecondary: Colors.white,
      error: const Color(0xFFba1b1b),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );
  } else if (colorValue == Colors.deepOrange.value) {
    result = const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.deepOrange,
      onPrimary: Colors.white,
      secondary: Color(0xFF77574e),
      onSecondary: Colors.white,
      error: Color(0xFFba1b1b),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );
  } else if (colorValue == Colors.brown.value) {
    result = const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.brown,
      onPrimary: Colors.white,
      secondary: Color(0xFF77574c),
      onSecondary: Colors.white,
      error: Color(0xFFba1b1b),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );
  } else if (colorValue == Colors.grey.value) {
    result = ColorScheme(
      brightness: Brightness.light,
      primary: Colors.grey.shade600,
      onPrimary: Colors.white,
      secondary: const Color(0xFF4a6367),
      onSecondary: Colors.white,
      error: const Color(0xFFba1b1b),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );
  } else if (colorValue == Colors.blueGrey.value) {
    result = const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.blueGrey,
      onPrimary: Colors.white,
      secondary: Color(0xFF4d616b),
      onSecondary: Colors.white,
      error: Color(0xFFba1b1b),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );
  } else {
    result = const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.black,
      onPrimary: Colors.white,
      secondary: Color(0xFF74575f),
      onSecondary: Colors.white,
      error: Color(0xFFba1b1b),
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );
  }

  return result;
}
