import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'NowPlaying.dart';

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
                  Text("ロード中"),
                ],
              ),
            );
          }
          if (item.data!.isEmpty) {
            return const Center(child: Text("曲が見つかりません"));
          }

          // 箱型のwidget
          return ListView.builder(
            // Listの要素数
            itemCount: item.data!.length,
            // Listの生成
            itemBuilder: (context, index) {
              // 全曲Listに取得した全てのitemをセット
              allSongs = item.data!;
              // Listに表示するwidgetのセット
              return ListTile(
                onTap: () {
                  // SongModelを更新
                  ref.read(SongModelProvider.notifier).state = item.data![index];
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
                  onPressed: () {},
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
