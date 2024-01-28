import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/class/song_class.dart';
import 'package:music_lyrics/screens/below_album_artist.dart';

import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/widgets/album_artist_info_dialog.dart';

class AllArtists extends ConsumerStatefulWidget {
  // 定数コンストラクタ
  const AllArtists({super.key});

  // stateの作成
  @override
  ConsumerState<AllArtists> createState() => _AllArtistsState();
}

class _AllArtistsState extends ConsumerState<AllArtists> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // アーティストタブのスクロールコントローラー
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
        itemCount: artistList.length,
        // Listの生成
        itemBuilder: (context, index) {
          return ListTile(
            tileColor: const Color(0xfffffbfe),
            onTap: () {
              // 一旦リストをクリア
              artistSongs.clear();
              // 収録曲リストにタップされたアルバムを追加
              for (Song song in songList) {
                if (song.artist == artistList[index].artist) {
                  artistSongs.add(song);
                }
              }
              // 曲順にソート
              artistSongs.sort((a, b) {
                // アルバムフリガナで比較
                int albumComparison = a.albumFuri!.toLowerCase().compareTo(b.albumFuri!.toLowerCase());

                if (albumComparison == 0) {
                  // アルバムフリガナが同じ場合は曲順で比較
                  return (a.track!).compareTo(b.track!);
                } else {
                  return albumComparison;
                }
              });

              // 下の階層に画面遷移
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BelowAlbumArtist(
                      queueList: artistSongs,
                      name: artistList[index].artist,
                      dispArtist: false,
                    ),
                  ));
            },
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: deviceWidth - 110,
                  child: Text(
                    artistList[index].artist!,
                    maxLines: 1,
                  ),
                ),
                Text(
                  artistList[index].numTracks.toString(),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            trailing: IconButton(
              onPressed: () {
                // 一旦リストをクリア
                artistSongs.clear();
                // 収録曲リストにタップされたアーティストを追加
                for (Song song in songList) {
                  if (song.artist == artistList[index].artist) {
                    artistSongs.add(song);
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
            // ListTile両端の余白
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          );
        },
      ),
    );
  }
}
