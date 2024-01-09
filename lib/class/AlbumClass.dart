class Album {
  int id; // アルバムの識別値
  String album; // アルバム名
  String album_furi; // アルバムのフリガナ
  String? artist; // アーティスト
  int numSongs; // 曲数

  Album({
    required this.id,
    required this.album,
    required this.album_furi,
    this.artist,
    required this.numSongs,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'album': album,
      'album_furi': album_furi,
      'artist': artist,
      'numSongs': numSongs,
    };
  }
}
