class Artist {
  int id; // アーティストの識別値
  String artist; // アーティスト名
  String artistFuri; //アーティストのフリガナ
  int? numTracks; // 曲数

  Artist({
    required this.id,
    required this.artist,
    required this.artistFuri,
    this.numTracks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'artist': artist,
      'artistFuri': artistFuri,
      'numTracks': numTracks,
    };
  }
}
