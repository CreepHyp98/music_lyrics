import 'package:music_lyrics/class/song_class.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SongDB {
  static final SongDB instance = SongDB._createInstance();
  static Database? _database;

  SongDB._createInstance();

  // databaseのインスタンス化
  Future<Database> get database async {
    return _database ??= await _initDB();
  }

  // databaseのオープン
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'songs.db');

    return openDatabase(
      path,
      // バージョン指定(指定しないとデータベースのアップデートで破損する可能性)
      version: 1,
      // songs.dbがなかったら作成
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE songs(id INTEGER PRIMARY KEY, title TEXT, titleFuri TEXT, artist TEXT, album TEXT, duration INTEGER, path TEXT, lyric TEXT)');
  }

  // データの挿入
  Future<int> insertSong(Song song) async {
    final Database db = await database;

    return await db.insert(
      'songs',
      song.toMap(),
      // conflictが発生したときは置き換える
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // データの取得
  Future<List<Song>> getAllSongs() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('songs');

    return List.generate(maps.length, (i) {
      return Song(
        id: maps[i]['id'],
        title: maps[i]['title'],
        titleFuri: maps[i]['titleFuri'],
        artist: maps[i]['artist'],
        album: maps[i]['album'],
        duration: maps[i]['duration'],
        path: maps[i]['path'],
        lyric: maps[i]['lyric'],
      );
    });
  }

  // データの更新
  Future<void> updateSong(Song song) async {
    final Database db = await database;
    await db.update(
      'songs',
      song.toMap(),
      // idで指定されたデータを更新
      where: "id = ?",
      whereArgs: [song.id],
      // conflictが発生したときは中止して継続
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // データの削除
  Future<void> deleteSong(int id) async {
    final Database db = await database;
    await db.delete(
      'songs',
      // idで指定されたデータを削除
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
