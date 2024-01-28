class Song {
  int? id; // レコードの識別値
  String? title; //タイトル
  String? titleFuri; //タイトルのフリガナ
  String? artist; // アーティスト
  String? album; // アルバム
  String? albumFuri; // アルバムのフリガナ
  int? track; // トラックNo.
  int? duration; // 曲時間
  String? path; // ファイルパス
  String? lyric; // 歌詞

  Song({
    this.id,
    this.title,
    this.titleFuri,
    this.artist,
    this.album,
    this.albumFuri,
    this.track,
    this.duration,
    this.path,
    this.lyric,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'titleFuri': titleFuri,
      'artist': artist,
      'album': album,
      'albumFuri': albumFuri,
      'track': track,
      'duration': duration,
      'path': path,
      'lyric': lyric,
    };
  }
}
