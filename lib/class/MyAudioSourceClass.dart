import 'package:just_audio/just_audio.dart';
import 'package:music_lyrics/class/SongClass.dart';
import 'package:music_lyrics/provider/provider.dart';

class MyAudioSource {
  // 定数コンストラクタ
  List<Song>? songList;
  int? songIndex;
  AudioPlayer? audioPlayer;

  MyAudioSource({this.songList, this.songIndex, this.audioPlayer});
}

void playSong(List<Song> songList, int songIndex, AudioPlayer audioPlayer) async {
  // 再生リストの初期化
  List<AudioSource> audioSourceList = [];

  // 受け取った曲リストを音源ファイルに変換し再生リストに加える
  for (var element in songList) {
    audioSourceList.add(
      // URI文字列 → URIオブジェクト → オーディオファイル
      AudioSource.file(element.path!),
    );
  }

  // 再生リストをプレイヤーにセット
  audioPlayer.setAudioSource(
    ConcatenatingAudioSource(children: audioSourceList),
    initialIndex: songIndex,
  );

  if (audioPlayer.hasNext == false) {
    ptc.jumpToTab(2);
  }

  // 再生
  audioPlayer.play();
}
