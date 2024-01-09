import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:music_lyrics/class/SongClass.dart';
import 'package:music_lyrics/class/AlbumClass.dart';
import 'package:music_lyrics/class/ArtistClass.dart';

import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

// 端末の横サイズ
double deviceWidth = 0;
// 端末の高さサイズ
double deviceHeight = 0;
// 保存されたデータを参照
late final SharedPreferences prefs;
// SongModelの状態を管理
final StateProvider<Song> SongProvider = StateProvider<Song>((ref) => Song());
final AudioPlayer audioPlayer = AudioPlayer();
// 再生リスト
List<Song> SongQueue = [];
// 全曲リスト
List<Song> SongList = [];
// アルバムリスト
List<Album> AlbumList = [];
// アルバム収録曲
List<Song> albumSongs = [];
// アーティストリスト
List<Artist> ArtistList = [];
// アーティスト該当曲
List<Song> artistSongs = [];
// リストインデックス
final StateProvider<int> IndexProvider = StateProvider<int>((ref) => 0);
// 再生時間を管理
final StateProvider<Duration> PositionProvider = StateProvider<Duration>((ref) => const Duration());
// 再生中の歌詞データを管理
final StateProvider<List<String>> LyricProvider = StateProvider<List<String>>(((ref) => [""]));
// 下タブのコントローラー
final PersistentTabController lowerTC = PersistentTabController();
// 曲リスト上タブのコントローラー
late TabController upperTC;
// 一つ下の階層（アルバム > 収録曲）に行くかフラグ
final StateProvider<bool> belowAlbum = StateProvider<bool>((ref) => false);
// 一つ下の階層（アーティスト > 該当曲）に行くかフラグ
final StateProvider<bool> belowArtist = StateProvider<bool>((ref) => false);
// 歌詞編集用SongModel
final StateProvider<Song> EditSongProvider = StateProvider<Song>((ref) => Song());
// 歌詞編集用AudioPlayer
final AudioPlayer EditAudioPlayer = AudioPlayer();
// 歌詞編集用再生時間
final StateProvider<Duration> EditPosiProvider = StateProvider<Duration>((ref) => const Duration());
// 歌詞編集用歌詞データ
final StateProvider<List<String>> EditLrcProvider = StateProvider<List<String>>(((ref) => [""]));
// 歌詞編集用テキストコントローラー
TextEditingController tec = TextEditingController();
// スプラッシュ画面に表示する[歌詞, 曲名, アーティスト名]のリスト
List<String> SplashTextList = ['', '', ''];
// チュートリアル用のキー
List<GlobalKey> key = [GlobalKey(), GlobalKey(), GlobalKey(), GlobalKey(), GlobalKey(), GlobalKey()];
// チュートリアル
TutorialCoachMark? tcm;
// 保存されてるカラー値のprovider
final StateProvider<int> ColorValueProvider = StateProvider<int>(((ref) => prefs.getInt('selectedColor') ?? Colors.blue.value));
