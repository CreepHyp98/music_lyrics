import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:music_lyrics/provider/SongModelProvider.dart';
import 'NowPlaying.dart';

class AllSongs extends StatefulWidget {
  // 定数コンストラクタ
  const AllSongs({Key? key}) : super(key: key);

  // stateの作成
  @override
  State<AllSongs> createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  // クラスのインスタンス化
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // 曲リストの初期化
  List<SongModel> allSongs = [];

  // 初回表示時の処理
  @override
  void initState() {
    super.initState();
    // アクセス許可のリクエスト
    requestPermission();
  }

  // アクセス許可のリクエスト
  void requestPermission() async {
    // Androidプラットフォームなら
    if (Platform.isAndroid) {
      // 許可状態の確認
      bool permissionStatus = await _audioQuery.permissionsStatus();
      // 許可状態が変わったら
      if (!permissionStatus) {
        // 許可のリクエスト
        await _audioQuery.permissionsRequest();
      }
      // 画面の再描画
      setState(() {});
    }
  }

  // widgetの生成
  @override
  Widget build(BuildContext context) {
    // 画面を構成するUI構造
    return Scaffold(
      // 画面上部のバー
      appBar: AppBar(
        title: const Text('全曲'),
      ),

      // 非同期かつ動的にwidgetを生成できるクラス
      body: FutureBuilder<List<SongModel>>(
        // buildのたびに呼ばれるメソッド
        future: _audioQuery.querySongs(
          sortType: null,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
          path: 'Music',
        ),

        // widgetの生成
        builder: (context, item) {
          if (item.data == null) {
            return Center(
              child: Column(
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text("ロード中")
                ],
              ),
            );
          }
          if (item.data!.isEmpty) {
            return const Center(child: Text("曲が見つかりません"));
          }

          // 自由に要素を並べるためのwidget
          return Stack(
            // 複数の子要素
            children: [
              // スクロールに対応したwidgetの生成
              ListView.builder(
                // Listの要素数
                itemCount: item.data!.length,
                // Listの生成
                itemBuilder: (context, index) {
                  // 全曲Listに取得した全てのitemをセット
                  allSongs = item.data!;

                  // タッチイベントを検出できるwidget
                  return GestureDetector(
                    onTap: () {
                      // ProviderからSongModelのidを受け取る（受け取ったデータを元にUIの構築を行わない）
                      context.read<SongModelProvider>().setId(item.data![index].id);
                      // ページ遷移（進む）
                      Navigator.push(
                        context,
                        // マテリアルデザインに則ったアニメーションを行う
                        MaterialPageRoute(
                          // NowPlayingクラスの生成
                          builder: (context) => NowPlaying(
                            // 全曲リストを渡す
                            songModelList: allSongs,
                            // タッチされた曲のidを渡す
                            songIndex: index,
                            // クラスのインスタンス化
                            audioPlayer: _audioPlayer,
                          ),
                        ),
                      );
                    },

                    // Listに表示するwidgetのセット
                    child: ListTile(
                      title: Text(item.data![index].title),
                      subtitle: Text("${item.data![index].artist}"),
                      trailing: const Icon(Icons.more_horiz),
                      leading: Card(
                        child: QueryArtworkWidget(
                          id: item.data![index].id,
                          type: ArtworkType.AUDIO,
                          artworkBorder: BorderRadius.circular(0),
                          nullArtworkWidget: const Icon(Icons.music_note),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
