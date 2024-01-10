import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/class/song_class.dart';
import 'package:music_lyrics/screens/music_list.dart';

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
  // 一つ下の階層のスクロールコントローラー
  final ScrollController _belowSC = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    _belowSC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scrollbar(
      controller: ref.watch(belowArtist) ? _belowSC : _scrollController,
      thickness: 12.0,
      radius: const Radius.circular(12.0),
      interactive: true,
      child: ref.watch(belowArtist)
          ? MusicList(playlist: artistSongs, dispArtist: false, sc: _belowSC)
          : ListView.builder(
              controller: _scrollController,
              // Listの要素数
              itemCount: artistList.length,
              // Listの生成
              itemBuilder: (context, index) {
                return ListTile(
                  tileColor: const Color(0xfffffbfe),
                  onTap: () {
                    setState(() {
                      // 一旦リストをクリア
                      artistSongs.clear();
                      // 収録曲リストにタップされたアルバムを追加
                      for (Song song in songList) {
                        if (song.artist == artistList[index].artist) {
                          artistSongs.add(song);
                        }
                      }
                      // 曲順にソート
                      artistSongs.sort(
                        (a, b) => (a.path!).compareTo(b.path!),
                      );

                      // 一つ下の階層へ
                      ref.read(belowArtist.notifier).state = true;
                    });
                  },
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        artistList[index].artist,
                        maxLines: 1,
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
                      // 収録曲リストにタップされたアルバムを追加
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
