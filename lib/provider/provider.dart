import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:music_lyrics/class/song_class.dart';
import 'package:music_lyrics/class/album_class.dart';
import 'package:music_lyrics/class/artist_class.dart';

import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

// 端末の横サイズ
double deviceWidth = 0;
// 端末の高さサイズ
double deviceHeight = 0;
// 保存されたデータを参照
late final SharedPreferences prefs;
// SongModelの状態を管理
final songProvider = StateProvider<Song>((ref) => Song());
final audioPlayer = AudioPlayer();
// 再生リスト
List<Song> songQueue = [];
// 全曲リスト
List<Song> songList = [];
// アルバムリスト
List<Album> albumList = [];
// アルバム収録曲
List<Song> albumSongs = [];
// アーティストリスト
List<Artist> artistList = [];
// アーティスト該当曲
List<Song> artistSongs = [];
// リストインデックス
final indexProvider = StateProvider<int>((ref) => 0);
// 再生時間を管理
final positionProvider = StateProvider<Duration>((ref) => const Duration());
// 再生中の歌詞データを管理
final lyricProvider = StateProvider<List<String>>(((ref) => [""]));
// 下タブのコントローラー
final lowerTC = PersistentTabController();
// 歌詞編集の「全体」「同期」のどちらが選択されているか
final isSelectedProvider = StateProvider<List<bool>>((ref) => [true, false]);
// 歌詞編集用SongModel
final editSongProvider = StateProvider<Song>((ref) => Song());
// 歌詞編集用AudioPlayer
final editAudioPlayer = AudioPlayer();
// 歌詞編集用再生時間
final editPosiProvider = StateProvider<Duration>((ref) => const Duration());
// 歌詞編集用歌詞データ(歌い出し時間は含まない)
List<String> editLrc = [];
// 歌詞編集用歌詞データの歌い出し時間(mm:ss:cc変換前のduration)
List<int> editStartTime = [];
// スプラッシュ画面に表示する[歌詞, 曲名, アーティスト名]のリスト
List<String> splashTextList = ['', '', ''];
// チュートリアル用のキー
List<GlobalKey> key = [GlobalKey(), GlobalKey(), GlobalKey(), GlobalKey(), GlobalKey(), GlobalKey()];
// チュートリアル
TutorialCoachMark? tcm;
// 保存されてるカラー値のprovider
final colorValueProvider = StateProvider<int>(((ref) => prefs.getInt('selectedColor') ?? Colors.blue.value));
