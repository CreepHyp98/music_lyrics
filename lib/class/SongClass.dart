class Song {
  int? id; // レコードの識別値
  String? title; //タイトル
  String? title_furi; //タイトルのフリガナ
  String? artist; // アーティスト
  String? album; // アルバム
  int? duration; // 曲時間
  String? path; // ファイルパス
  String? lyric; // 歌詞

  Song({
    this.id,
    this.title,
    this.title_furi,
    this.artist,
    this.album,
    this.duration,
    this.path,
    this.lyric,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'title_furi': title_furi,
      'artist': artist,
      'album': album,
      'duration': duration,
      'path': path,
      'lyric': lyric,
    };
  }
}
