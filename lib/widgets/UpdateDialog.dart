import 'package:flutter/material.dart';
import 'package:music_lyrics/class/SongClass.dart';
import 'package:music_lyrics/class/AlbumClass.dart';
import 'package:music_lyrics/class/ArtistClass.dart';

import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/screens/MainPage.dart';
import 'package:music_lyrics/screens/TextConvert.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:music_lyrics/class/SongDB.dart';
import 'package:music_lyrics/class/AlbumDB.dart';
import 'package:music_lyrics/class/ArtistDB.dart';

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

    // データベースに登録されているデータを取得
    List<Song> currentAllSong = await SongDB.instance.getAllSongs();
    List<Album> currentAllAlbum = await AlbumDB.instance.getAllAlbums();
    List<Artist> currentAllArtist = await ArtistDB.instance.getAllArtists();

    // デバイス内の楽曲ファイルを取得
    List<SongModel> smList = await audioQuery.querySongs();
    List<AlbumModel> alList = await audioQuery.queryAlbums();
    List<ArtistModel> arList = await audioQuery.queryArtists();

    // 全曲データベースの構築
    for (int i = 0; i < smList.length; i++) {
      // 曲登録済みかフラグを初期化
      exist = false;

      // データベースに同じidの楽曲があるか探す
      for (Song currentSong in currentAllSong) {
        if (smList[i].id == currentSong.id) {
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

        await SongDB.instance.insertSong(song);
      }

      // 進捗状況を更新
      if (mounted) {
        setState(() {
          widget.progress = i / (smList.length + alList.length + arList.length);
        });
      }
    }

    // アルバムデータベースの構築
    for (int i = 0; i < alList.length; i++) {
      // アルバム登録済みかフラグを初期化
      exist = false;

      // データベースに同じidのアルバムがあるか探す
      for (Album currentAlbum in currentAllAlbum) {
        if (alList[i].id == currentAlbum.id) {
          exist = true;

          // 登録済みのアルバムと曲数が異なるかチェック
          if (alList[i].numOfSongs != currentAlbum.numSongs) {
            // 曲数の更新
            currentAlbum.numSongs = alList[i].numOfSongs;
            AlbumDB.instance.updateAlbum(currentAlbum);
          }

          break;
        }
      }

      // 登録済みフラグがfalseのままだったらそのアルバムを追加
      if (exist == false) {
        final album = Album(
          id: alList[i].id,
          album: alList[i].album,
          album_furi: await getFurigana(alList[i].album),
          artist: alList[i].artist,
          numSongs: alList[i].numOfSongs,
        );

        await AlbumDB.instance.insertAlbum(album);
      }

      // 進捗状況を更新
      if (mounted) {
        setState(() {
          widget.progress = (smList.length + i) / (smList.length + alList.length + arList.length);
        });
      }
    }

    // アーティストデータベースの構築
    // なぜか同じアーティストが別々に分かれる場合があるので構築前に重複チェックする
    Set<String> uniqueArtistNames = {};
    List<ArtistModel> mergedArtists = [];
    for (ArtistModel am in arList) {
      if (uniqueArtistNames.contains(am.artist) == false) {
        uniqueArtistNames.add(am.artist);
        mergedArtists.add(am);
      }
    }
    arList = mergedArtists;

    for (int i = 0; i < arList.length; i++) {
      // アーティスト登録済みかフラグを初期化
      exist = false;

      // データベースに同じ名前のアーティストがいるか探す
      for (Artist currentArtist in currentAllArtist) {
        if (arList[i].artist == currentArtist.artist) {
          exist = true;
          break;
        }
      }

      // 登録済みフラグがfalseのままだったらそのアーティストを追加
      if (exist == false) {
        final artist = Artist(
          id: arList[i].id,
          artist: arList[i].artist,
          artist_furi: await getFurigana(arList[i].artist),
          // numTracksの追加は別で行う
        );

        await ArtistDB.instance.insertArtist(artist);
      }

      // 進捗状況を更新
      if (mounted) {
        setState(() {
          widget.progress = (smList.length + alList.length + i) / (smList.length + alList.length + arList.length);
        });
      }
    }

    // numTracksの追加
    currentAllSong = await SongDB.instance.getAllSongs();
    currentAllArtist = await ArtistDB.instance.getAllArtists();
    for (Artist currentArtist in currentAllArtist) {
      // 曲数カウンタ初期化
      int count = 0;
      for (Song currentSong in currentAllSong) {
        if (currentSong.artist == currentArtist.artist) {
          count++;
        }
      }

      // 曲数の更新
      currentArtist.numTracks = count;
      await ArtistDB.instance.updateArtist(currentArtist);
    }

    setState(() {
      _done = true;
    });
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
              style: TextStyle(fontSize: 20),
            )
          : const Text(
              "更新中...",
              style: TextStyle(fontSize: 20),
            ),
      content: _done
          // 更新完了
          ? null

          // 更新中
          : SizedBox(
              height: 50,
              child: Column(
                children: [
                  const Text('フリガナを取得しているため\n少し時間がかかります'),
                  const Spacer(),
                  LinearProgressIndicator(
                    value: widget.progress,
                  ),
                ],
              ),
            ),
      actions: [
        _done
            ? GestureDetector(
                child: const Text(
                  '閉じる',
                  style: TextStyle(fontSize: 15),
                ),
                onTap: () {
                  // ホーム画面の再構築
                  Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => route.isCurrent);
                  lowerTC.jumpToTab(0);
                },
              )
            : GestureDetector(
                onTap: () {
                  // ダイアログを閉じる
                  Navigator.pop(context);
                },
                child: const Text(
                  'キャンセル',
                  style: TextStyle(fontSize: 15),
                ),
              ),
      ],
    );
  }
}
