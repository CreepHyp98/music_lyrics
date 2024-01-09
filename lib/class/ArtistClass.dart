class Artist {
  int id; // アーティストの識別値
  String artist; // アーティスト名
  String artist_furi; //アーティストのフリガナ
  int? numTracks; // 曲数

  Artist({
    required this.id,
    required this.artist,
    required this.artist_furi,
    this.numTracks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'artist': artist,
      'artist_furi': artist_furi,
      'numTracks': numTracks,
    };
  }
}
