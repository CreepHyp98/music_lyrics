import 'package:flutter/material.dart';
import 'package:music_lyrics/class/SongClass.dart';
import 'package:music_lyrics/class/SongDB.dart';
import 'package:music_lyrics/provider/provider.dart';

import 'package:on_audio_query/on_audio_query.dart';
import 'AllSongs.dart';
import 'TextConvert.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // List<SongModel>から楽曲データベースの作成
  Future<void> createSongDB() async {
    final OnAudioQuery audioQuery = OnAudioQuery();
    bool exist;

    // データベースに登録されている全楽曲を取得
    List<Song> currentAllSong = await songsDB.instance.getAllSongs();

    // デバイス内の楽曲ファイルを取得
    List<SongModel> smList = await audioQuery.querySongs(
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    for (int i = 0; i < smList.length; i++) {
      // 曲登録済みかフラグを初期化
      exist = false;

      // データベースに同じidの楽曲があるか探す
      for (int j = 0; j < currentAllSong.length; j++) {
        if (smList[i].id == currentAllSong[j].id) {
          exist = true;
          break;
        }
      }

      // 登録済みフラグがfalseのままだったらその曲を追加
      if ((exist == false) && (smList[i].isMusic == true)) {
        final song = Song(
          id: smList[i].id,
          title: smList[i].title,
          title_furi: await getFurigana(smList[i].title),
          artist: smList[i].artist,
          album: smList[i].album,
          duration: smList[i].duration,
          path: smList[i].data,
          lyric: await copyLyric(smList[i].data),
        );

        await songsDB.instance.insertSong(song);
      }
    }
  }

  /// Futureを受け取り、それが完了したらダイアログを自動的に閉じる。
  void showFutureLoader(BuildContext context, Future future) {
    final dialog = AlertDialog(
      content: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SizedBox(
                height: 80,
                child: Column(
                  children: [
                    const Text('更新が終わりました'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      child: const Text('OK'),
                      onPressed: () {
                        // ホーム画面の再構築
                        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => route.isCurrent);
                        ptc.jumpToTab(0);
                      },
                    ),
                  ],
                ),
              );
            }
            return Row(
              children: [
                const CircularProgressIndicator(),
                Container(margin: const EdgeInsets.only(left: 7), child: const Text("Loading...")),
              ],
            );
          }),
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.autorenew),
          title: const Text('楽曲ライブラリの更新'),
          onTap: () {
            // ダイアログ表示
            showFutureLoader(context, createSongDB());
          },
        )
      ],
    );
  }
}
