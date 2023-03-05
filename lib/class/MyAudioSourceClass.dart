import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MyAudioSource {
  // 定数コンストラクタ
  List<SongModel>? songModelList;
  int? songIndex;
  AudioPlayer? audioPlayer;

  MyAudioSource({this.songModelList, this.songIndex, this.audioPlayer});
}

void parseSong(List<SongModel> songModelList, int songIndex, AudioPlayer audioPlayer) {
  // 再生リストの初期化
  List<AudioSource> audioSourceList = [];

  // 受け取った曲リストを音源ファイルに変換し再生リストに加える
  for (var element in songModelList) {
    audioSourceList.add(
      // URI文字列 → URIオブジェクト → オーディオファイル
      AudioSource.uri(
        Uri.parse(element.uri!),
        tag: MediaItem(
          id: element.id.toString(),
          title: element.title,
          artist: element.artist,
        ),
      ),
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
