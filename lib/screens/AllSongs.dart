import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_lyrics/class/MyAudioSourceClass.dart';
import 'package:music_lyrics/widgets/LyricWidget.dart';
import 'package:music_lyrics/widgets/SettingDialogWidget.dart';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:music_lyrics/provider/provider.dart';

class AllSongs extends ConsumerStatefulWidget {
  // 定数コンストラクタ
  const AllSongs({super.key});

  // stateの作成
  @override
  ConsumerState<AllSongs> createState() => _AllSongsState();
}

class _AllSongsState extends ConsumerState<AllSongs> {
  // クラスのインスタンス化
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // アクセス許可のフラグ
  bool _hasPermission = false;

  // 曲リストの初期化
  List<SongModel> allSongs = [];
  // タイトルとそのフリガナのマップ
  Map<String, String> furiganaMap = {};

  // 初回表示時の処理
  @override
  void initState() {
    super.initState();
    // アクセス許可のリクエスト
    checkAndRequestPermissions();
  }

  // アクセス許可のリクエスト
  checkAndRequestPermissions({bool retry = false}) async {
    _hasPermission = await _audioQuery.checkAndRequest(
      retryRequest: retry,
    );

    // 許可されたら画面を再描画
    _hasPermission ? setState(() {}) : null;
  }

  Widget noAccessToLibraryWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.redAccent.withOpacity(0.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("ライブラリへのアクセス許可がありません"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => checkAndRequestPermissions(retry: true),
            child: const Text("アクセス許可"),
          ),
        ],
      ),
    );
  }

  void sortAllSongs() async {
    try {
      for (int i = 0; i < allSongs.length; i++) {
        // タイトルのフリガナを持ってくる
        String? furigana = prefs.getString(allSongs[i].title);
        furiganaMap[allSongs[i].title] = furigana!;
      }
      // フリガナで五十音順にソート
      allSongs.sort(
        // TODO: アルファベットが大文字→小文字の順になってる
        (a, b) => furiganaMap[a.title]!.compareTo(furiganaMap[b.title]!),
      );
    } catch (e) {
      // タイトル取得中
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // 非同期かつ動的にwidgetを生成できるクラス
        body: Center(
          child: !_hasPermission
              ? noAccessToLibraryWidget()
              : FutureBuilder<List<SongModel>>(
                  future: _audioQuery.querySongs(
                    orderType: OrderType.ASC_OR_SMALLER,
                    uriType: UriType.EXTERNAL,
                    ignoreCase: true,
                    path: 'Music',
                  ),

                  // widgetの生成
                  builder: (context, item) {
                    if (item.hasError) {
                      return Text(item.error.toString());
                    }

                    if (item.data == null) {
                      return const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            Text("ロード中"),
                          ],
                        ),
                      );
                    }
                    if (item.data!.isEmpty) {
                      return const Center(child: Text("曲が見つかりません"));
                    }

                    return ListView.builder(
                      // Listの要素数
                      itemCount: item.data!.length,
                      // Listの生成
                      itemBuilder: (context, index) {
                        // 全曲Listに取得した全てのitemをセット
                        allSongs = item.data!;
                        // フリガナがない曲はAPIを使って生成
                        // TODO: HandShakeExceptionが発生するため一時的にコメントアウト
                        //setFuriganaAll(allSongs);
                        // 曲のフリガナで五十音順にソート
                        //sortAllSongs();

                        return ListTile(
                          onTap: () {
                            // SongModelを更新
                            ref.read(SongModelProvider.notifier).state = item.data![index];

                            // TODO: 仮のスプラッシュ画面のためにタップした曲の情報を保存
                            prefs.setStringList('splash', [
                              '',
                              item.data![index].title,
                              '${item.data![index].artist}',
                            ]);

                            // リスト・インデックス・プレイヤーをセットし、再生
                            ref.read(AudioProvider.notifier).state = MyAudioSource(
                              songModelList: allSongs,
                              songIndex: index,
                              audioPlayer: _audioPlayer,
                            );

                            // オーディオファイルに変換し再生
                            parseSong(
                              ref.watch(AudioProvider).songModelList!,
                              ref.watch(AudioProvider).songIndex!,
                              ref.watch(AudioProvider).audioPlayer!,
                            );

                            // TODO: コピータイミングは検討必要
                            copyLyricFile(item.data![index]);

                            // NowPlayingに遷移
                            ptc.jumpToTab(1);
                          },
                          title: Text(
                            item.data![index].title,
                            maxLines: 1,
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${item.data![index].artist}",
                                maxLines: 1,
                              ),
                              Text(IntDurationToMS(item.data![index].duration)),
                            ],
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              // 歌詞編集用SongModelに今開いてる曲をセット
                              ref.read(EditSMProvider.notifier).state = item.data![index];
                              // 歌詞データの取得
                              getLyric(ref, EditSMProvider, EditLrcProvider);

                              // ダイアログ表示
                              showDialog(
                                context: context,
                                builder: (context) => SettingDialog(
                                  defaultFurigana: furiganaMap[item.data![index].title],
                                ),
                              );
                            },
                            icon: const Icon(Icons.more_horiz),
                          ),
                          leading: QueryArtworkWidget(
                            id: item.data![index].id,
                            type: ArtworkType.AUDIO,
                            artworkBorder: BorderRadius.circular(0),
                            artworkFit: BoxFit.contain,
                            nullArtworkWidget: const Icon(Icons.music_note),
                          ),
                          // leadingとtitleの幅
                          horizontalTitleGap: 5,
                          // ListTile両端の余白
                          contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}

String IntDurationToMS(int? time) {
  String result;

  int minutes = (time! / (1000 * 60)).floor();
  int seconds = ((time / 1000) % 60).floor();

  if (seconds < 10) {
    result = "$minutes:0$seconds";
  } else {
    result = "$minutes:$seconds";
  }

  return result;
}

void copyLyricFile(SongModel sm) async {
  // 絶対パスの拡張子のインデックスを取得
  int extensionIndex = sm.data.lastIndexOf('.');

  try {
    // コピー元となる.lrcファイルのパスをセット
    String sourcePath = '${sm.data.substring(0, extensionIndex)}.lrc';
    // コピー先のディレクトリを取得
    Directory destinationFolder = Directory('${directory.path}/${sm.artist!}/${sm.album!}');
    // ディレクトリが存在しない場合は作成
    if (destinationFolder.existsSync() == false) {
      destinationFolder.createSync(recursive: true);
    }
    // ファイルのコピー
    File(sourcePath).copySync('${destinationFolder.path}/${sm.displayNameWOExt}.lrc');
  } catch (e) {
    // .lrcファイルがない場合、何もしない
  }
}
