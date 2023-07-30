import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/widgets/BottomPlayerBar.dart';
import 'package:music_lyrics/widgets/LrcListView.dart';
import 'package:music_lyrics/widgets/LrcTextField.dart';
import 'package:url_launcher/url_launcher.dart';

class LyricEdit extends ConsumerStatefulWidget {
  const LyricEdit({super.key});

  @override
  ConsumerState<LyricEdit> createState() => _LyricEditState();
}

class _LyricEditState extends ConsumerState<LyricEdit> {
  // ToggleButton選択中かどうか
  final List<bool> _isSelected = <bool>[true, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TextField入力時、上にずれてしまうのを防ぐ
      //resizeToAvoidBottomInset: false,
      // 上バー
      appBar: AppBar(
        // 画面スクロールで色が変わるのを防ぐ
        scrolledUnderElevation: 0,
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

        // 歌詞データの全体／同期表示
        centerTitle: true,
        title: SizedBox(
          height: 40,
          child: ToggleButtons(
            isSelected: _isSelected,
            onPressed: (index) {
              // 切り替えるたびにテキストフィールドのコントローラーと歌詞プロバイダーを更新
              tec = TextEditingController(text: ref.watch(EditLrcProvider).join('\n'));
              ref.read(EditLrcProvider.notifier).state = tec.text.split('\n');

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
                child: const Text('全体'),
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
            onPressed: () {
              // 再生中のオーディオファイルの絶対パスを取得
              String audioPath = ref.watch(EditSMProvider).data;
              // その絶対パスの拡張子のインデックスを取得
              int extensionIndex = audioPath.lastIndexOf('.');
              // .lrcファイルのパスをセット
              String lyricPath = '${audioPath.substring(0, extensionIndex)}.lrc';
              // パス → ファイル
              File lyricFile = File(lyricPath);
              // ファイル書き込み
              lyricFile.writeAsStringSync(tec.text);
              // ダイアログに戻る
              Navigator.pop(context);
            },
          ),
        ],
      ),

      // 中央にはTextFieldもしくはListViewの歌詞
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: _isSelected[0] ? const LrcTextField() : const LrcListView(),
          ),
        ],
      ),

      // 下バーは"全体"なら検索などのボタン、"同期"なら再生バー
      bottomNavigationBar: _isSelected[0]
          ? BottomAppBar(
              // 画面スクロールで色が変わるのを防ぐ
              elevation: 0,
              child: Row(
                children: [
                  // 検索ボタン
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search),
                        Text('検索'),
                      ],
                    ),
                    onPressed: () {
                      // 検索キーワード
                      String keyword = "${ref.watch(EditSMProvider).title} ${ref.watch(EditSMProvider).artist!} 歌詞";
                      // 検索エンジンを開く
                      launchUrl(Uri.parse('https://www.google.com/search?q=$keyword'));
                    },
                  ),

                  // 空行削除ボタン
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.remove_circle_outline),
                        Text('空行削除'),
                      ],
                    ),
                    onPressed: () {
                      List<String> lines = tec.text.split('\n');
                      lines.removeWhere((line) => line.isEmpty);
                      tec.text = lines.join('\n');
                    },
                  ),
                ],
              ),
            )
          : const BottomPlayerBar(),
    );
  }
}
