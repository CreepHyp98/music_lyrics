import 'package:music_lyrics/class/artist_class.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ArtistDB {
  static final ArtistDB instance = ArtistDB._createInstance();
  static Database? _database;

  ArtistDB._createInstance();

  // databaseのインスタンス化
  Future<Database> get database async {
    return _database ??= await _initDB();
  }

  // databaseのオープン
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'artists.db');

    return openDatabase(
      path,
      // バージョン指定(指定しないとデータベースのアップデートで破損する可能性)
      version: 1,
      // artists.dbがなかったら作成
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE artists(id INTEGER PRIMARY KEY, artist TEXT, artistFuri TEXT, numTracks INTEGER)');
  }

  // データの挿入
  Future<int> insertArtist(Artist artist) async {
    final Database db = await database;

    return await db.insert(
      'artists',
      artist.toMap(),
      // conflictが発生したときは置き換える
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // データの取得
  Future<List<Artist>> getAllArtists() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('artists');

    return List.generate(maps.length, (i) {
      return Artist(
        id: maps[i]['id'],
        artist: maps[i]['artist'],
        artistFuri: maps[i]['artistFuri'],
        numTracks: maps[i]['numTracks'],
      );
    });
  }

  // データの更新
  Future<void> updateArtist(Artist artist) async {
    final Database db = await database;
    await db.update(
      'artists',
      artist.toMap(),
      // idで指定されたデータを更新
      where: "id = ?",
      whereArgs: [artist.id],
      // conflictが発生したときは中止して継続
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // データの削除
  Future<void> deleteArtist(String name) async {
    final Database db = await database;
    await db.delete(
      'artists',
      // idで指定されたデータを削除
      where: "artist = ?",
      whereArgs: [name],
    );
  }
}
