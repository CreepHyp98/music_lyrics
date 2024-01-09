import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/class/AlbumClass.dart';
import 'package:music_lyrics/class/AlbumDB.dart';
import 'package:music_lyrics/class/ArtistClass.dart';
import 'package:music_lyrics/class/ArtistDB.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/class/SongDB.dart';

class DeleteDialog extends ConsumerWidget {
  const DeleteDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text(
        '本当に削除しますか？',
        style: TextStyle(fontSize: 20),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Text(
                'キャンセル',
                style: TextStyle(fontSize: 15),
              ),
            ),
            GestureDetector(
              onTap: () {
                // 全曲データベースから削除
                SongDB.instance.deleteSong(ref.watch(EditSongProvider).id!);

                String albumName = ref.watch(EditSongProvider).album!;
                for (Album album in AlbumList) {
                  if (albumName == album.album) {
                    if (album.numSongs == 1) {
                      // アルバム最後の一曲だったらアルバムデータベースから削除
                      AlbumDB.instance.deleteAlbum(albumName);
                    } else {
                      // 最後の一曲じゃなければ曲数-1でデータベース更新
                      album.numSongs = album.numSongs - 1;
                      AlbumDB.instance.updateAlbum(album);
                    }
                  }
                }

                String artistName = ref.watch(EditSongProvider).artist!;
                for (Artist artist in ArtistList) {
                  if (artistName == artist.artist) {
                    if (artist.numTracks == 1) {
                      // アーティスト最後の一曲だったらアーティストデータベースからも削除
                      ArtistDB.instance.deleteArtist(artistName);
                    } else {
                      // 最後の一曲じゃなければ曲数-1でデータベース更新
                      artist.numTracks = artist.numTracks! - 1;
                      ArtistDB.instance.updateArtist(artist);
                    }
                  }
                }

                // 階層をすべて上に戻す
                ref.read(belowAlbum.notifier).state = false;
                ref.read(belowArtist.notifier).state = false;

                // 遷移元の画面を破棄してホーム画面へ
                Navigator.of(context).pushReplacementNamed("/home");
              },
              child: Text(
                '削除する',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
