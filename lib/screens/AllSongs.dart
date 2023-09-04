import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_lyrics/class/MyAudioSourceClass.dart';
import 'package:music_lyrics/class/SongClass.dart';
import 'package:music_lyrics/widgets/SettingDialogWidget.dart';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/class/SongDB.dart';

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
  // 曲リスト取得したかのフラグ
  bool _hasList = false;

  // 曲リストの初期化
  List<Song> allSongs = [];

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

  // データベースから全曲リスト取得
  Future<void> setAllSongs() async {
    if (_hasList == false) {
      allSongs = await songsDB.instance.getAllSongs();
      _hasList = true;
      sortFurigana(allSongs);
    }
  }

  void sortFurigana(List<Song> s) async {
    // フリガナで五十音順にソート
    s.sort(
      (a, b) => (a.title_furi!.toLowerCase()).compareTo(b.title_furi!.toLowerCase()),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // アクセスが許可されたらデータベースの構築(すでに構築されてたらしない)
    if (_hasPermission == true) {
      setAllSongs();
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: (_hasPermission == false)
              ? noAccessToLibraryWidget()
              : (_hasList == false)
                  ? const Column(
                      children: [
                        CircularProgressIndicator(),
                        Text("ロード中"),
                      ],
                    )
                  : (allSongs.isEmpty == true)
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.settings),
                            Text('の「楽曲ライブラリの更新」をタップしてください'),
                          ],
                        )
                      : Scrollbar(
                          thickness: 12.0,
                          radius: const Radius.circular(12.0),
                          interactive: true,
                          child: ListView.builder(
                            // Listの要素数
                            itemCount: allSongs.length,
                            // Listの生成
                            itemBuilder: (context, index) {
                              return ListTile(
                                onTap: () {
                                  // SongProviderを更新
                                  ref.read(SongProvider.notifier).state = allSongs[index];
                                  // LyricProviderを更新
                                  if (allSongs[index].lyric != null) {
                                    ref.read(LyricProvider.notifier).state = allSongs[index].lyric!.split('\n');
                                  } else {
                                    ref.read(LyricProvider.notifier).state = [''];
                                  }

                                  // リスト・インデックス・プレイヤーをセットし、再生
                                  ref.read(AudioProvider.notifier).state = MyAudioSource(
                                    songList: allSongs,
                                    songIndex: index,
                                    audioPlayer: _audioPlayer,
                                  );

                                  // オーディオファイルに変換し再生
                                  parseSong(
                                    ref.watch(AudioProvider).songList!,
                                    ref.watch(AudioProvider).songIndex!,
                                    ref.watch(AudioProvider).audioPlayer!,
                                  );

                                  // NowPlayingに遷移
                                  ptc.jumpToTab(1);
                                },
                                title: Text(
                                  allSongs[index].title!,
                                  maxLines: 1,
                                ),
                                subtitle: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${allSongs[index].artist}",
                                      maxLines: 1,
                                    ),
                                    Text(IntDurationToMS(allSongs[index].duration)),
                                  ],
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    // 歌詞編集用SongModelに今開いてる曲をセット
                                    ref.read(EditSongProvider.notifier).state = allSongs[index];
                                    // EditLrcProviderを更新
                                    if (allSongs[index].lyric != null) {
                                      ref.read(EditLrcProvider.notifier).state = allSongs[index].lyric!.split('\n');
                                    } else {
                                      ref.read(EditLrcProvider.notifier).state = [''];
                                    }

                                    // ダイアログ表示
                                    showDialog(
                                      context: context,
                                      builder: (context) => SettingDialog(
                                        defaultFurigana: allSongs[index].title_furi,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.more_horiz),
                                ),
                                leading: QueryArtworkWidget(
                                  id: allSongs[index].id!,
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
                          ),
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

Future<String?> copyLyric(String path) async {
  // 絶対パスの拡張子のインデックスを取得
  int extensionIndex = path.lastIndexOf('.');

  try {
    // コピー元となる.lrcファイルのパスをセット
    String lyricPath = '${path.substring(0, extensionIndex)}.lrc';
    // パス → ファイル
    File lyricFile = File(lyricPath);
    // ファイル → String
    String lyricData = await lyricFile.readAsString();
    // 空行を削除する
    List<String> lines = lyricData.split('\n');
    lines.removeWhere((line) => line.isEmpty);
    lyricData = lines.join('\n');

    return lyricData;
  } catch (e) {
    // .lrcファイルがない場合はnullを返す
    return null;
  }
}
