import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/class/song_class.dart';
import 'package:music_lyrics/screens/below_album_artist.dart';
import 'package:music_lyrics/widgets/album_artist_info_dialog.dart';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:music_lyrics/provider/provider.dart';

class AllAlbums extends ConsumerStatefulWidget {
  // 定数コンストラクタ
  const AllAlbums({super.key});

  // stateの作成
  @override
  ConsumerState<AllAlbums> createState() => _AllAlbumsState();
}

class _AllAlbumsState extends ConsumerState<AllAlbums> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // アルバムタブのスクロールコントローラー
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scrollbar(
      controller: _scrollController,
      thickness: 12.0,
      radius: const Radius.circular(12.0),
      interactive: true,
      child: ListView.builder(
        controller: _scrollController,
        // Listの要素数
        itemCount: albumList.length,
        // Listの生成
        itemBuilder: (context, index) {
          return ListTile(
            tileColor: const Color(0xfffffbfe),
            onTap: () {
              // 一旦リストをクリア
              albumSongs.clear();
              // 収録曲リストにタップされたアルバムを追加
              for (Song song in songList) {
                if (song.album == albumList[index].album) {
                  albumSongs.add(song);
                }
              }
              // 曲順にソート
              albumSongs.sort(
                (a, b) => (a.path!).compareTo(b.path!),
              );

              // 下の階層に画面遷移
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BelowAlbumArtist(
                      queueList: albumSongs,
                      name: albumList[index].album,
                      dispArtist: true,
                    ),
                  ));
            },
            title: Text(
              albumList[index].album!,
              maxLines: 1,
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${albumList[index].artist}",
                  maxLines: 1,
                ),
                Text(albumList[index].numSongs.toString()),
              ],
            ),
            trailing: IconButton(
              onPressed: () {
                // 一旦リストをクリア
                albumSongs.clear();
                // 収録曲リストにタップされたアルバムを追加
                for (Song song in songList) {
                  if (song.album == albumList[index].album) {
                    albumSongs.add(song);
                  }
                }

                // ダイアログ表示
                showDialog(
                  context: context,
                  builder: (context) => AlbumArtistInfoDialog(index: index),
                );
              },
              icon: const Icon(Icons.more_horiz),
            ),
            leading: QueryArtworkWidget(
              id: albumList[index].id!,
              type: ArtworkType.ALBUM,
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
    );
  }
}
