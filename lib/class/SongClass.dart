class Song {
  int? id; // レコードの識別値
  String? title; //タイトル
  String? artist; // アーティスト
  String? album; // アルバム
  int? duration; // 曲時間
  String? path; // ファイルパス

  Song({
    this.id,
    this.title,
    this.artist,
    this.album,
    this.duration,
    this.path,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration,
      'path': path,
    };
  }
}
