class Album {
  String? album; // アルバム名
  String? albumFuri; // アルバムのフリガナ
  String? artist; // アーティスト
  int? numSongs; // 曲数

  Album({
    this.album,
    this.albumFuri,
    this.artist,
    this.numSongs,
  });

  Map<String, dynamic> toMap() {
    return {
      'album': album,
      'albumFuri': albumFuri,
      'artist': artist,
      'numSongs': numSongs,
    };
  }
}
