class Song {
  int? id; // レコードの識別値
  String? title; //タイトル
  String? titleFuri; //タイトルのフリガナ
  String? artist; // アーティスト
  String? album; // アルバム
  int? albumId; // アルバムID
  int? duration; // 曲時間
  String? path; // ファイルパス
  String? lyric; // 歌詞

  Song({
    this.id,
    this.title,
    this.titleFuri,
    this.artist,
    this.album,
    this.albumId,
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
      'albumId': albumId,
      'duration': duration,
      'path': path,
      'lyric': lyric,
    };
  }
}
