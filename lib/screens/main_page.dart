import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/screens/all_albums.dart';
import 'package:music_lyrics/screens/all_artists.dart';
import 'package:music_lyrics/screens/music_list.dart';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/class/song_database.dart';
import 'package:music_lyrics/class/album_database.dart';
import 'package:music_lyrics/class/artist_database.dart';

class MainPage extends ConsumerStatefulWidget {
  // 定数コンストラクタ
  const MainPage({super.key});

  // stateの作成
  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> with SingleTickerProviderStateMixin {
  // クラスのインスタンス化
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final ScrollController _scrollController = ScrollController();
  late final TabController _tabController;

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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // アクセス許可のリクエスト
  checkAndRequestPermissions({bool retry = false}) async {
    _hasPermission = await _audioQuery.checkAndRequest(
      retryRequest: retry,
    );

    // 許可されたら画面を再描画
    _hasPermission
        ? setState(() {
            setAllLists();
          })
        : null;
  }

  Widget noAccessToLibraryWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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
    songList = await SongDB.instance.getAllSongs();
    albumList = await AlbumDB.instance.getAllAlbums();
    artistList = await ArtistDB.instance.getAllArtists();

    // フリガナで五十音順にソート
    songList.sort(
      (a, b) => (a.titleFuri!.toLowerCase()).compareTo(b.titleFuri!.toLowerCase()),
    );
    albumList.sort(
      (a, b) => (a.albumFuri!.toLowerCase()).compareTo(b.albumFuri!.toLowerCase()),
    );
    artistList.sort(
      (a, b) => (a.artistFuri!.toLowerCase()).compareTo(b.artistFuri!.toLowerCase()),
    );

    setState(() {
      _hasList = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(deviceWidth, 45),
        child: AppBar(
          // 画面スクロールで色が変わるのを防ぐ
          scrolledUnderElevation: 0,

          // 上タブバー
          bottom: TabBar(
            controller: _tabController,
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
              : (songList.isEmpty == true)
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
                      controller: _tabController,
                      children: [
                        // 全曲リスト
                        MusicList(
                          playlist: songList,
                          dispArtist: true,
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
