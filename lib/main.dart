import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:music_lyrics/provider/SongModelProvider.dart';
import 'screens/AllSongs.dart';

void main() {
  // widget配置用のデバッグフラグ
  debugPaintSizeEnabled = true;

  runApp(
    // notifyListeners()が宣言された時、変数を変更できるようにするウィジェット
    ChangeNotifierProvider(
      // ChangeNotifierを継承した状態管理オブジェクトを生成
      create: (context) => SongModelProvider(),
      // 子要素
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // 定数コンストラクタ
  const MyApp({Key? key}) : super(key: key);

  // widgetの生成
  @override
  Widget build(BuildContext context) {
    // アプリケーション全体
    return MaterialApp(
      // テーマデータ
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "Noto Sans JP",
      ),
      // 初期表示のクラス
      home: const AllSongs(),
    );
  }
}
