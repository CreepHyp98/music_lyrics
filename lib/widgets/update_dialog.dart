import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music_lyrics/class/song_class.dart';
import 'package:music_lyrics/class/album_class.dart';
import 'package:music_lyrics/class/artist_class.dart';

import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/screens/text_convert.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:music_lyrics/class/song_database.dart';
import 'package:music_lyrics/class/album_database.dart';
import 'package:music_lyrics/class/artist_database.dart';

// プログレスバーの更新のためfinal修飾子はつけない
// ignore: must_be_immutable
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

    // Songクラスでアルバムフリガナを使うため、初めにアルバムデータベースを構築する
    for (int i = 0; i < alList.length; i++) {
      // アルバム登録済みかフラグを初期化
      exist = false;

      // データベースに同じアルバム名とアーティスト名のアルバムがあるか探す
      for (Album currentAlbum in currentAllAlbum) {
        if ((alList[i].album == currentAlbum.album) && (alList[i].artist == currentAlbum.artist)) {
          exist = true;
          break;
        }
      }

      // 登録済みフラグがfalseのままだったらそのアルバムを追加
      if (exist == false) {
        final album = Album(
          album: alList[i].album,
          albumFuri: await getFurigana(alList[i].album),
          artist: alList[i].artist,
          // numSongsの追加は別でおこなう
        );

        await AlbumDB.instance.insertAlbum(album);
      }

      // 進捗状況を更新
      if (mounted) {
        setState(() {
          widget.progress = i / (alList.length + smList.length + arList.length);
        });
      }
    }

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
          titleFuri: await getFurigana(smList[i].title),
          artist: smList[i].artist,
          album: smList[i].album,
          albumFuri: await AlbumDB.instance.getAlbumFuri(smList[i].album!, smList[i].artist!),
          track: smList[i].track,
          duration: smList[i].duration,
          path: smList[i].data,
          lyric: await copyLyric(smList[i].data),
        );

        await SongDB.instance.insertSong(song);
      }

      // 進捗状況を更新
      if (mounted) {
        setState(() {
          widget.progress = (i + alList.length) / (alList.length + smList.length + arList.length);
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
          artist: arList[i].artist,
          artistFuri: await getFurigana(arList[i].artist),
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

    // アルバムnumSongsの追加
    currentAllSong = await SongDB.instance.getAllSongs();
    currentAllAlbum = await AlbumDB.instance.getAllAlbums();
    for (Album currentAlbum in currentAllAlbum) {
      // 曲数カウンタ初期化
      int count = 0;
      for (Song currentSong in currentAllSong) {
        if ((currentSong.album == currentAlbum.album) && (currentSong.artist == currentAlbum.artist)) {
          count++;
        }
      }

      // 曲数の更新
      currentAlbum.numSongs = count;
      await AlbumDB.instance.updateAlbum(currentAlbum);
    }

    // アーティストnumTracksの追加
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
                  Text('フリガナを取得しているため\n少し時間がかかります (${(widget.progress * 100).floor()}%)'),
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

Future<String?> copyLyric(String path) async {
  // 絶対パスの拡張子のインデックスを取得
  int extensionIndex = path.lastIndexOf('.');

  try {
    // コピー元となる.lrcファイルのパスをセット
    String lyricPath = '${path.substring(0, extensionIndex)}.lrc';
    // パス → ファイル
    File lyricFile = File(lyricPath);
    // ファイル → String
    String lyricData = await lyricFile.readAsString();
    List<String> lines = lyricData.split('\n');
    // 空行の削除&ラスト一文字何か入ってるのでそれは含まない
    lines = lines.where((line) => line.isNotEmpty).map((line) => line.substring(0, line.length - 1)).toList();
    // 改行コードでつないでおわり
    lyricData = lines.join('\n');

    return lyricData;
  } catch (e) {
    // .lrcファイルがない場合はnullを返す
    return null;
  }
}
