import 'package:flutter/material.dart';
import 'package:music_lyrics/class/SongClass.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/screens/AllSongs.dart';
import 'package:music_lyrics/screens/TextConvert.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:music_lyrics/class/SongDB.dart';

class UpdateDialog extends StatefulWidget {
  double progress;
  bool doneOnce;
  UpdateDialog({super.key, required this.progress, required this.doneOnce});

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _done = false;

  // List<SongModel>から楽曲データベースの作成
  Future<void> createSongDB() async {
    // setStateで再実行しないようフラグをオフする
    widget.doneOnce = false;

    final OnAudioQuery audioQuery = OnAudioQuery();
    bool exist;

    // データベースに登録されている全楽曲を取得
    List<Song> currentAllSong = await songsDB.instance.getAllSongs();

    // デバイス内の楽曲ファイルを取得
    List<SongModel> smList = await audioQuery.querySongs();

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
      if ((exist == false) && (smList[i].duration! > 5000)) {
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

      // 進捗状況を更新
      if (mounted) {
        setState(() {
          widget.progress = i / smList.length;
        });
      }
    }

    _done = true;
  }

  @override
  Widget build(BuildContext context) {
    // ライブラリ更新の関数を一度だけ呼ぶ(setState対策)
    if (widget.doneOnce == true) {
      createSongDB();
    }

    return AlertDialog(
      title: _done
          ? const Text(
              '更新終了',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            )
          : const Text(
              "更新中...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
      // ダイアログ外のタップを無効にする
      content: _done
          // 更新完了
          ? null

          // 更新中
          : LinearProgressIndicator(
              value: widget.progress,
            ),

      actionsAlignment: MainAxisAlignment.center,
      actions: [
        _done
            ? ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  // ホーム画面の再構築
                  Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => route.isCurrent);
                  ptc.jumpToTab(0);
                },
              )
            : ElevatedButton(
                onPressed: () async {
                  // ダイアログを閉じる
                  Navigator.pop(context);
                },
                child: const Text('キャンセル'),
              ),
      ],
    );
  }
}
