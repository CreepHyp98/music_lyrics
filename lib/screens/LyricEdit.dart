import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:music_lyrics/class/BannerAdManager.dart';
import 'package:music_lyrics/class/SongDB.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/screens/Tutorial.dart';
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
  List<bool> _isSelected = <bool>[true, false];
  // チュートリアルを表示するか
  late bool firstEdit_1;
  late bool firstEdit_2;

  @override
  void initState() {
    // チュートリアルの表示するか確認
    firstEdit_1 = prefs.getBool('tutorial_1') ?? true;
    firstEdit_2 = prefs.getBool('tutorial_2') ?? true;

    // 初めての編集ならチュートリアル画面に遷移
    if (firstEdit_1 == true) {
      WidgetsBinding.instance.addPostFrameCallback(
        (Duration duration) {
          showTutorial(context, 1);
        },
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // バナー広告の読み込み
    BannerAd myBanner = createBannerAd();
    myBanner.load();

    return WillPopScope(
      // デバイスのバックイベント時の処理
      onWillPop: () async {
        // 再生ストップ
        EditAudioPlayer.stop();
        // 編集用再生位置も初期化
        ref.read(EditPosiProvider.notifier).state = Duration.zero;

        // チュートリアル画面終了
        if (tcm != null) {
          tcm!.finish();
        }

        return true;
      },
      child: Scaffold(
        // TextField入力時、上にずれてしまうのを防ぐ
        //resizeToAvoidBottomInset: false,
        // 上バー
        appBar: AppBar(
          // 画面スクロールで色が変わるのを防ぐ
          scrolledUnderElevation: 0,
          titleSpacing: deviceWidth / 60,
          // ×ボタン
          leading: IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () {
              // 再生ストップ
              EditAudioPlayer.stop();
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
                // 「全体」がタップされたら
                if (index == 0) {
                  // TextFieldのコントローラーに歌詞プロバイダーをセット
                  tec = TextEditingController(text: ref.watch(EditLrcProvider).join('\n'));
                  // 編集用AudioPlayer一時停止
                  EditAudioPlayer.pause();
                  _isSelected = [true, false];
                  setState(() {});

                  // 「同期」がタップされたら
                } else {
                  // 歌詞プロバイダーにTextFieldの入力をセット
                  ref.read(EditLrcProvider.notifier).state = tec.text.split('\n');
                  _isSelected = [false, true];

                  // 初めての編集ならチュートリアル画面に遷移
                  if (firstEdit_2 == true) {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (Duration duration) {
                        showTutorial(context, 2);
                      },
                    );
                  }

                  setState(() {});
                }
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
                  key: key[2],
                  alignment: Alignment.center,
                  width: 120,
                  child: const Text('同期'),
                ),
              ],
            ),
          ),

          // 完了ボタン
          actions: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: IconButton(
                key: key[5],
                icon: Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  // 再生ストップ
                  EditAudioPlayer.stop();
                  // 編集用再生位置も初期化
                  ref.read(EditPosiProvider.notifier).state = Duration.zero;

                  // 編集用プロバイダーのlyricにtextfieldの値をセット
                  tec = TextEditingController(text: ref.watch(EditLrcProvider).join('\n'));
                  ref.read(EditSongProvider.notifier).state.lyric = tec.text;
                  // データベースを更新
                  songsDB.instance.updateSong(ref.watch(EditSongProvider));

                  // ダイアログに戻る
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),

        // 中央にはTextFieldもしくはListViewの歌詞
        body: Align(
          alignment: Alignment.center,
          child: _isSelected[0] ? LrcTextField(key: key[0]) : const LrcListView(),
        ),

        // 下バーは"全体"なら検索などのボタン、"同期"なら再生バー
        bottomNavigationBar: _isSelected[0]
            ? BottomAppBar(
                // 画面スクロールで色が変わるのを防ぐ
                elevation: 0,
                // 下側の余白のみ削除
                padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                height: deviceHeight * 0.14,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        // 検索ボタン
                        OutlinedButton(
                          key: key[1],
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
                            String keyword = "${ref.watch(EditSongProvider).title} ${ref.watch(EditSongProvider).artist!} lyricjp";
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

                        // インフォメーションマーク
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.info_outline,
                          ),
                          onPressed: () {
                            WidgetsBinding.instance.addPostFrameCallback(
                              (Duration duration) {
                                showTutorial(context, 1);
                              },
                            );
                          },
                        ),
                      ],
                    ),

                    // バナー広告
                    const SizedBox(height: 5),
                    SizedBox(
                      height: myBanner.size.height.toDouble(),
                      width: myBanner.size.width.toDouble(),
                      child: AdWidget(ad: myBanner),
                    ),
                  ],
                ),
              )
            : const BottomPlayerBar(),
      ),
    );
  }
}
