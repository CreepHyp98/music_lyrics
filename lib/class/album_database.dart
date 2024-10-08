import 'package:music_lyrics/class/album_class.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AlbumDB {
  static final AlbumDB instance = AlbumDB._createInstance();
  static Database? _database;

  AlbumDB._createInstance();

  // databaseのインスタンス化
  Future<Database> get database async {
    return _database ??= await _initDB();
  }

  // databaseのオープン
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'albums.db');

    return openDatabase(
      path,
      // バージョン指定(指定しないとデータベースのアップデートで破損する可能性)
      version: 1,
      // albums.dbがなかったら作成
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE albums(album TEXT, albumFuri TEXT, artist TEXT, numSongs INTEGER, PRIMARY KEY(album, artist))');
  }

  // データの挿入
  Future<int> insertAlbum(Album album) async {
    final Database db = await database;

    return await db.insert(
      'albums',
      album.toMap(),
      // conflictが発生したときは置き換える
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // データの取得
  Future<List<Album>> getAllAlbums() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('albums');

    return List.generate(maps.length, (i) {
      return Album(
        album: maps[i]['album'],
        albumFuri: maps[i]['albumFuri'],
        artist: maps[i]['artist'],
        numSongs: maps[i]['numSongs'],
      );
    });
  }

  // アルバムフリガナの取得
  Future<String?> getAlbumFuri(String albumName, String artistName) async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'albums',
      where: 'album = ? AND artist = ?',
      whereArgs: [albumName, artistName],
    );
    if (result.isNotEmpty) {
      return result.first['albumFuri'];
    } else {
      return null;
    }
  }

  // データの更新
  Future<void> updateAlbum(Album album) async {
    final Database db = await database;
    await db.update(
      'albums',
      album.toMap(),
      // アルバム名とアーティスト名で指定されたデータを更新
      where: 'album = ? AND artist = ?',
      whereArgs: [album.album, album.artist],
      // conflictが発生したときは中止して継続
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // データの削除
  Future<void> deleteAlbum(Album album) async {
    final Database db = await database;
    await db.delete(
      'albums',
      // アルバム名とアーティスト名で指定されたデータを更新
      where: 'album = ? AND artist = ?',
      whereArgs: [album.album, album.artist],
    );
  }
}
