import 'package:flutter/material.dart';
import 'package:music_lyrics/class/song_class.dart';
import 'package:music_lyrics/screens/music_list.dart';

class BelowAlbumArtist extends StatelessWidget {
  final List<Song> queueList;
  final String? name;
  final bool dispArtist;
  const BelowAlbumArtist({super.key, required this.queueList, this.name, required this.dispArtist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 画面スクロールで色が変わるのを防ぐ
        scrolledUnderElevation: 0,

        // 戻るボタン
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // ダイアログに戻る
            Navigator.pop(context);
          },
        ),

        // アルバム名 or アーティスト名
        title: Text(
          name!,
          style: const TextStyle(fontSize: 20),
        ),
      ),

      // 曲リスト
      body: MusicList(
        playlist: queueList,
        dispArtist: dispArtist,
      ),
    );
  }
}
