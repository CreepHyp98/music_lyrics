import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:music_lyrics/class/banner_ad_manager.dart';
import 'package:music_lyrics/class/song_database.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/screens/tutorial.dart';
import 'package:music_lyrics/widgets/bottom_player_bar.dart';
import 'package:music_lyrics/widgets/lrc_listview.dart';
import 'package:music_lyrics/widgets/lyric_text.dart';
import 'package:url_launcher/url_launcher.dart';

class LyricEdit extends ConsumerStatefulWidget {
  const LyricEdit({super.key});

  @override
  ConsumerState<LyricEdit> createState() => _LyricEditState();
}

class _LyricEditState extends ConsumerState<LyricEdit> {
  // テキストフィールドのコントローラー
  final tec = TextEditingController();
  // テキストフィールドを初期化するかどうか
  bool _doneOnce = true;

  @override
  void initState() {
    super.initState();

    // 初めての編集ならチュートリアル画面に遷移
    bool firstEdit_1 = prefs.getBool('tutorial_1') ?? true;
    if (firstEdit_1 == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 100));
        showTutorial(context, 1);
      });
    }

    // 歌い出し時間のリストを-1で初期化
    editStartTime = List.generate(editLrc.length, (index) => -1);
  }

  @override
  void dispose() {
    tec.dispose();
    super.dispose();
  }

  // 歌いだし時間と歌詞データを結合
  List<String> combineStartTimeAndLrc() {
    List<String> tempLrc = List.generate(editLrc.length, (index) => '');

    for (int i = 0; i < editLrc.length; i++) {
      // 歌い出し時間があればそのまま結合、なければ歌詞データのみ
      if (editStartTime[i] != -1) {
        tempLrc[i] = "[${milliToMinSec(editStartTime[i])}]${editLrc[i]}";
      } else {
        tempLrc[i] = editLrc[i];
      }
    }

    return tempLrc;
  }

  @override
  Widget build(BuildContext context) {
    // バナー広告の読み込み
    BannerAd myBanner = createBannerAd();
    myBanner.load();
    // 初回表示時のみ編集用歌詞データをセット
    if (_doneOnce == true) {
      String? inputText = ref.watch(editSongProvider).lyric;
      if (inputText != null) {
        tec.text = inputText;
      }
      _doneOnce = false;
    }

    return WillPopScope(
      // デバイスのバックイベント時の処理
      onWillPop: () async {
        // 再生ストップ
        editAudioPlayer.stop();
        // 編集用再生位置も初期化
        ref.read(editPosiProvider.notifier).state = Duration.zero;

        // チュートリアル画面終了
        if (tcm != null) {
          tcm!.finish();
        }

        return true;
      },
      child: Scaffold(
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
              editAudioPlayer.stop();
              // 編集用再生位置も初期化
              ref.read(editPosiProvider.notifier).state = Duration.zero;

              // ダイアログに戻る
              Navigator.pop(context);
            },
          ),

          // 歌詞データの全体／同期表示
          centerTitle: true,
          title: SizedBox(
            height: 40,
            child: ToggleButtons(
              isSelected: ref.watch(isSelectedProvider),
              onPressed: (index) {
                // 「全体」のときに「同期」がタップされたら
                if ((ref.watch(isSelectedProvider)[0] == true) && (index == 1)) {
                  // 歌詞プロバイダーにTextFieldの入力をセット
                  editLrc = tec.text.split('\n');

                  for (int i = 0; i < editLrc.length; i++) {
                    // 歌い出し時間のセット
                    editStartTime[i] = getLyricStartTime(editLrc[i]);

                    // 歌詞データのセット
                    if (getLyricStartTime(editLrc[i]) != -1) {
                      editLrc[i] = editLrc[i].substring(10);
                    }
                  }

                  // 初めての編集ならチュートリアル画面に遷移
                  bool firstEdit_2 = prefs.getBool('tutorial_2') ?? true;
                  if (firstEdit_2 == true) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Future.delayed(const Duration(milliseconds: 100));
                      showTutorial(context, 2);
                    });
                  }

                  ref.read(isSelectedProvider.notifier).state = [false, true];
                }

                // 「同期」のときに「全体」がタップされたら
                if ((ref.watch(isSelectedProvider)[1] == true) && (index == 0)) {
                  // 歌い出し時間と歌詞データをくっつけて、TextFieldのコントローラーに歌詞プロバイダーをセット
                  tec.text = combineStartTimeAndLrc().join('\n');

                  // 編集用AudioPlayer一時停止
                  editAudioPlayer.pause();

                  ref.read(isSelectedProvider.notifier).state = [true, false];
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
                  editAudioPlayer.stop();
                  // 編集用再生位置も初期化
                  ref.read(editPosiProvider.notifier).state = Duration.zero;

                  // 編集用プロバイダーのlyricに歌詞データをセット
                  if (ref.watch(isSelectedProvider)[0] == true) {
                    ref.read(editSongProvider.notifier).state.lyric = tec.text;
                  } else {
                    ref.read(editSongProvider.notifier).state.lyric = combineStartTimeAndLrc().join('\n');
                  }

                  // データベースを更新
                  SongDB.instance.updateSong(ref.watch(editSongProvider));
                  // ダイアログに戻る
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),

        // 中央にはTextFieldもしくはListViewの歌詞
        body: Center(
          child: ref.watch(isSelectedProvider)[0]
              // TextField
              ? Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: SizedBox(
                    width: deviceWidth * 0.9,
                    // キーボードが出たときの画面下端からキーボード上端までの高さを考慮する
                    height: deviceHeight - (MediaQuery.of(context).viewInsets.bottom),
                    child: TextField(
                      controller: tec,
                      style: const TextStyle(fontSize: 15),
                      maxLines: 50,
                      decoration: const InputDecoration(
                        labelText: '歌詞データ',
                        // ラベルテキストを常に浮かす
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                )
              // ListView
              : const LrcListView(),
        ),

        // 下バーは"全体"なら検索などのボタン、"同期"なら再生バー
        bottomNavigationBar: ref.watch(isSelectedProvider)[0]
            ? BottomAppBar(
                // 画面スクロールで色が変わるのを防ぐ
                elevation: 0,
                // 下側の余白のみ削除
                padding: const EdgeInsets.only(left: 19.0, right: 8.0),
                height: deviceHeight * 0.12,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                            String keyword = "${ref.watch(editSongProvider).title} ${ref.watch(editSongProvider).artist!} lyricjp";
                            // 検索エンジンを開く
                            launchUrl(Uri.parse('https://www.google.com/search?q=$keyword'));
                          },
                        ),

                        // 空行削除ボタン
                        const SizedBox(width: 5),
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
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Future.delayed(const Duration(milliseconds: 100));
                              showTutorial(context, 1);
                            });
                          },
                        ),
                      ],
                    ),

                    // バナー広告
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
