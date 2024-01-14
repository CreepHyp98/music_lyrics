class Artist {
  String? artist; // アーティスト名
  String? artistFuri; //アーティストのフリガナ
  int? numTracks; // 曲数

  Artist({
    this.artist,
    this.artistFuri,
    this.numTracks,
  });

  Map<String, dynamic> toMap() {
    return {
      'artist': artist,
      'artistFuri': artistFuri,
      'numTracks': numTracks,
    };
  }
}
