import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/screens/MusicList.dart';

import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/widgets/Album_ArtistInfoDialog.dart';

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
  final ScrollController _SC = ScrollController();
  // 一つ下の階層のスクロールコントローラー
  final ScrollController _belowSC = ScrollController();

  @override
  void dispose() {
    _SC.dispose();
    _belowSC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scrollbar(
      controller: ref.watch(belowArtist) ? _belowSC : _SC,
      thickness: 12.0,
      radius: const Radius.circular(12.0),
      interactive: true,
      child: ref.watch(belowArtist)
          ? MusicList(PlayList: artistSongs, dispArtist: false, sc: _belowSC)
          : ListView.builder(
              controller: _SC,
              // Listの要素数
              itemCount: ArtistList.length,
              // Listの生成
              itemBuilder: (context, index) {
                return ListTile(
                  tileColor: const Color(0xfffffbfe),
                  onTap: () {
                    setState(() {
                      // 一旦リストをクリア
                      artistSongs.clear();
                      // 収録曲リストにタップされたアルバムを追加
                      for (int i = 0; i < SongList.length; i++) {
                        if (SongList[i].artist == ArtistList[index].artist) {
                          artistSongs.add(SongList[i]);
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
                        ArtistList[index].artist,
                        maxLines: 1,
                      ),
                      Text(
                        ArtistList[index].numTracks.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      // 一旦リストをクリア
                      artistSongs.clear();
                      // 収録曲リストにタップされたアルバムを追加
                      for (int i = 0; i < SongList.length; i++) {
                        if (SongList[i].artist == ArtistList[index].artist) {
                          artistSongs.add(SongList[i]);
                        }
                      }

                      // ダイアログ表示
                      showDialog(
                        context: context,
                        builder: (context) => Album_ArtistInfoDialog(index: index),
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
