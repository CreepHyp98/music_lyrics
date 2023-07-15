import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/widgets/BottomPlayerBar.dart';
import 'package:music_lyrics/widgets/LrcListView.dart';
import 'package:music_lyrics/widgets/LrcTextField.dart';

class LyricEdit extends ConsumerStatefulWidget {
  const LyricEdit({super.key});

  @override
  ConsumerState<LyricEdit> createState() => _LyricEditState();
}

class _LyricEditState extends ConsumerState<LyricEdit> {
  // ToggleButton選択中かどうか
  final List<bool> _isSelected = <bool>[true, false];

  Future<String> getLyric2() async {
    String lrcData = '';

    try {
      // 歌詞変種用のプロバイダーを参照してパスを取得
      String audioPath = ref.watch(EditSMProvider).data;
      // 絶対パスで拡張子のインデックスを取得
      int extensionIndex = audioPath.lastIndexOf('.');
      // .lrcファイルのパスをセット
      String lyricPath = '${audioPath.substring(0, extensionIndex)}.lrc';
      // パス → ファイル
      File lyricFile = File(lyricPath);
      // ファイル → String
      lrcData = await lyricFile.readAsString();
      return lrcData;
    } catch (e) {
      // .lrcファイルがない場合は空データのまま
      return lrcData;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 編集する曲を取得
    String filePath = ref.watch(EditSMProvider).data;
    // パスを使ってプレイヤーにセット
    ref.watch(EditAPProvider).setFilePath(filePath);

    return Scaffold(
      // TextField入力時、上にずれてしまうのを防ぐ
      //resizeToAvoidBottomInset: false,
      // 上バー
      appBar: AppBar(
        // 閉じるボタン
        leading: IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: () {
            // 編集用AudioPlayerを初期化
            ref.watch(EditAPProvider).dispose();
            ref.read(EditAPProvider.notifier).state = AudioPlayer();
            // 編集用再生位置も初期化
            ref.read(EditPosiProvider.notifier).state = Duration.zero;
            // ダイアログに戻る
            Navigator.pop(context);
          },
        ),

        // 歌詞データのシンプル／同期表示
        centerTitle: true,
        title: SizedBox(
          height: 40,
          child: ToggleButtons(
            isSelected: _isSelected,
            onPressed: (index) {
              setState(() {
                if (index == 0) {
                  _isSelected[0] = true;
                  _isSelected[1] = false;
                } else {
                  _isSelected[0] = false;
                  _isSelected[1] = true;
                }
              });
            },
            selectedBorderColor: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            children: [
              Container(
                alignment: Alignment.center,
                width: 120,
                child: const Text('シンプル'),
              ),
              Container(
                alignment: Alignment.center,
                width: 120,
                child: const Text('同期'),
              ),
            ],
          ),
        ),

        // 完了ボタン
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {},
          ),
        ],
      ),

      // 中央にはTextFieldもしくはListViewの歌詞
      body: Stack(
        children: [
          Align(
            alignment: const Alignment(0.0, -0.8),
            child: FutureBuilder(
              // .lrcファイルからStringに変換
              future: getLyric2(),
              builder: (context, snapshot) {
                // ファイルの読み込みが終わったらwidget表示
                // 「シンプル」が選択されてたらTextField
                if (snapshot.hasData && _isSelected[0] == true) {
                  String? result = snapshot.data;
                  return LrcTextField(data: result);

                  //「同期」が選択、かつデータが空じゃなければTextFieldのListView
                } else if (snapshot.hasData && _isSelected[1] == true) {
                  String? result = snapshot.data;
                  if (result != '') {
                    return LrcListView(lrcData: result);
                  } else {
                    return Container();
                  }
                } else {
                  return Container();
                }
              },
            ),
          ),
        ],
      ),

      // 下バー
      bottomNavigationBar: const BottomPlayerBar(),
    );
  }
}
