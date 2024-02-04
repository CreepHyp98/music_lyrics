import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/class/album_database.dart';
import 'package:music_lyrics/class/artist_database.dart';
import 'package:music_lyrics/class/song_class.dart';
import 'package:music_lyrics/class/song_database.dart';
import 'package:music_lyrics/provider/provider.dart';

class AlbumArtistInfoDialog extends ConsumerWidget {
  final int index;
  final int tabIndex;
  const AlbumArtistInfoDialog({super.key, required this.index, required this.tabIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TextFieldの入力text
    final TextEditingController furiController;
    if (tabIndex == 1) {
      furiController = TextEditingController(text: albumList[index].albumFuri);
    } else {
      furiController = TextEditingController(text: artistList[index].artistFuri);
    }
    // カーソルの位置を末尾に設定
    furiController.selection = TextSelection.fromPosition(TextPosition(offset: furiController.text.length));

    return AlertDialog(
      // タイトル（左寄せ）
      title: Text(
        (tabIndex == 1) ? albumList[index].album! : artistList[index].artist!,
        style: const TextStyle(fontSize: 20),
        textAlign: TextAlign.left,
        maxLines: 1,
      ),
      content: TextField(
        controller: furiController,
        decoration: InputDecoration(
          labelText: (tabIndex == 1) ? 'アルバムのフリガナ' : 'アーティストのフリガナ',
          // ラベルテキストを常に浮かす
          floatingLabelBehavior: FloatingLabelBehavior.always,
          // 入力文字と下線の隙間を埋める
          contentPadding: EdgeInsets.zero,
        ),
      ),

      actions: [
        // 閉じる
        GestureDetector(
          onTap: () {
            // 入力されたフリガナでデータベースを更新
            if (tabIndex == 1) {
              albumList[index].albumFuri = furiController.text;
              AlbumDB.instance.updateAlbum(albumList[index]);
              // Songクラスのほうも更新
              for (Song song in songList) {
                if ((song.album == albumList[index].album) && (song.artist == albumList[index].artist)) {
                  song.albumFuri = furiController.text;
                  SongDB.instance.updateSong(song);
                }
              }
            } else {
              artistList[index].artistFuri = furiController.text;
              ArtistDB.instance.updateArtist(artistList[index]);
            }

            // ダイアログを閉じる
            Navigator.pop(context);
          },
          child: const Text(
            '閉じる',
            style: TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }
}
