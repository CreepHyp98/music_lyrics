class Album {
  int? id; // アルバムの識別値
  String? album; // アルバム名
  String? albumFuri; // アルバムのフリガナ
  String? artist; // アーティスト
  int? numSongs; // 曲数

  Album({
    this.id,
    this.album,
    this.albumFuri,
    this.artist,
    this.numSongs,
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
