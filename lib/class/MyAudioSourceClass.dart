import 'package:just_audio/just_audio.dart';
import 'package:music_lyrics/class/SongClass.dart';

class MyAudioSource {
  // 定数コンストラクタ
  List<Song>? songList;
  int? songIndex;
  AudioPlayer? audioPlayer;

  MyAudioSource({this.songList, this.songIndex, this.audioPlayer});
}

void parseSong(List<Song> songList, int songIndex, AudioPlayer audioPlayer) {
  // 再生リストの初期化
  List<AudioSource> audioSourceList = [];

  // 受け取った曲リストを音源ファイルに変換し再生リストに加える
  for (var element in songList) {
    audioSourceList.add(
        // URI文字列 → URIオブジェクト → オーディオファイル
        AudioSource.file(element.path!)
        /*
      AudioSource.uri(
        Uri.parse(element.uri!),
        tag: MediaItem(
          id: element.id.toString(),
          title: element.title!,
          artist: element.artist,
        ),
      ),
      */
        );
  }

  // 再生リストをプレイヤーにセット
  audioPlayer.setAudioSource(
    ConcatenatingAudioSource(children: audioSourceList),
    initialIndex: songIndex,
  );

  // 再生
  audioPlayer.play();
}
