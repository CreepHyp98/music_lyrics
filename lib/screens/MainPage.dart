import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/screens/AllAlbums.dart';
import 'package:music_lyrics/screens/AllArtists.dart';
import 'package:music_lyrics/screens/MusicList.dart';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/class/SongDB.dart';
import 'package:music_lyrics/class/AlbumDB.dart';
import 'package:music_lyrics/class/ArtistDB.dart';

class MainPage extends ConsumerStatefulWidget {
  // 定数コンストラクタ
  const MainPage({super.key});

  // stateの作成
  @override
  ConsumerState<MainPage> createState() => _AllSongsState();
}

class _AllSongsState extends ConsumerState<MainPage> with SingleTickerProviderStateMixin {
  // クラスのインスタンス化
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final ScrollController _SC = ScrollController();

  // アクセス許可のフラグ
  bool _hasPermission = false;
  // 曲リスト取得したかのフラグ
  bool _hasList = false;

  // 初回表示時の処理
  @override
  void initState() {
    super.initState();
    // アクセス許可のリクエスト
    checkAndRequestPermissions();
    // タブバーのコントローラーをインスタンス化
    upperTC = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _SC.dispose();
    super.dispose();
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

  // データベースからそれぞれのリストを取得
  Future<void> setAllLists() async {
    if (_hasList == false) {
      SongList = await SongDB.instance.getAllSongs();
      AlbumList = await AlbumDB.instance.getAllAlbums();
      ArtistList = await ArtistDB.instance.getAllArtists();

      setState(() {
        // フリガナで五十音順にソート
        SongList.sort(
          (a, b) => (a.title_furi!.toLowerCase()).compareTo(b.title_furi!.toLowerCase()),
        );
        AlbumList.sort(
          (a, b) => (a.album_furi.toLowerCase()).compareTo(b.album_furi.toLowerCase()),
        );
        ArtistList.sort(
          (a, b) => (a.artist_furi.toLowerCase()).compareTo(b.artist_furi.toLowerCase()),
        );
      });

      _hasList = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // アクセスが許可されたらデータベースの構築(すでに構築されてたらしない)
    if (_hasPermission == true) {
      setAllLists();
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(deviceWidth, 45),
        child: AppBar(
          // 画面スクロールで色が変わるのを防ぐ
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: (() {
              // アルバムのタブ、かつ一つ下の階層？
              if ((upperTC.index == 1) && (ref.watch(belowAlbum) == true)) {
                // 上の階層に戻る
                ref.read(belowAlbum.notifier).state = false;

                // アーティストのタブ、かつ一つ下の階層？
              } else if ((upperTC.index == 2) && (ref.watch(belowArtist) == true)) {
                // 上の階層に戻る
                ref.read(belowArtist.notifier).state = false;
              }
            }),
            icon: const Icon(Icons.arrow_back),
            color: upperTC.index == 0
                ? Colors.white
                : ((upperTC.index == 1) && (ref.watch(belowAlbum))) || ((upperTC.index == 2) && (ref.watch(belowArtist)))
                    ? Colors.black
                    : Colors.white,
            // タップ時の色を無くす
            highlightColor: Colors.white,
          ),

          // 上タブバー
          bottom: TabBar(
            controller: upperTC,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(
                height: 40,
                child: Text(
                  '全曲',
                  style: TextStyle(fontSize: 15),
                ),
              ),
              Tab(
                height: 40,
                child: Text(
                  'アルバム',
                  style: TextStyle(fontSize: 15),
                ),
              ),
              Tab(
                height: 40,
                child: Text(
                  'アーティスト',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
      body: (_hasPermission == false)
          ? Center(child: noAccessToLibraryWidget())
          : (_hasList == false)
              ? const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      Text("ロード中"),
                    ],
                  ),
                )
              : (SongList.isEmpty == true)
                  ? const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.settings),
                          Text('の「楽曲ライブラリの更新」をタップしてください'),
                        ],
                      ),
                    )
                  : TabBarView(
                      controller: upperTC,
                      children: [
                        // 全曲リスト
                        MusicList(
                          PlayList: SongList,
                          dispArtist: true,
                          sc: _SC,
                        ),
                        // アルバムリスト
                        const AllAlbums(),
                        // アーティストリスト
                        const AllArtists(),
                      ],
                    ),
    );
  }
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
