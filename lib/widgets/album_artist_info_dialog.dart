import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/class/album_database.dart';
import 'package:music_lyrics/class/artist_database.dart';
import 'package:music_lyrics/provider/provider.dart';

class AlbumArtistInfoDialog extends ConsumerWidget {
  final int index;
  const AlbumArtistInfoDialog({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TextFieldの入力text
    final TextEditingController furiController;
    if (upperTC.index == 1) {
      furiController = TextEditingController(text: albumList[index].albumFuri);
    } else {
      furiController = TextEditingController(text: artistList[index].artistFuri);
    }
    // カーソルの位置を末尾に設定
    furiController.selection = TextSelection.fromPosition(TextPosition(offset: furiController.text.length));

    return AlertDialog(
      // タイトル（左寄せ）
      title: Text(
        (upperTC.index == 1) ? albumList[index].album : artistList[index].artist,
        style: const TextStyle(fontSize: 20),
        textAlign: TextAlign.left,
        maxLines: 1,
      ),
      content: TextField(
        controller: furiController,
        decoration: InputDecoration(
          labelText: (upperTC.index == 1) ? 'アルバムのフリガナ' : 'アーティストのフリガナ',
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
            if (upperTC.index == 1) {
              albumList[index].albumFuri = furiController.text;
              AlbumDB.instance.updateAlbum(albumList[index]);
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
