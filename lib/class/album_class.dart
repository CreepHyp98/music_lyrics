class Album {
  int id; // アルバムの識別値
  String album; // アルバム名
  String albumFuri; // アルバムのフリガナ
  String? artist; // アーティスト
  int numSongs; // 曲数

  Album({
    required this.id,
    required this.album,
    required this.albumFuri,
    this.artist,
    required this.numSongs,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'album': album,
      'albumFuri': albumFuri,
      'artist': artist,
      'numSongs': numSongs,
    };
  }
}
