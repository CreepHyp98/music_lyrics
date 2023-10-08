import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_lyrics/class/MyAudioSourceClass.dart';
import 'package:music_lyrics/class/SongClass.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 端末の横サイズ
double deviceWidth = 0;
// 端末の高さサイズ
double deviceHeight = 0;
// 保存されたデータを参照
late final SharedPreferences prefs;
// SongModelの状態を管理
final StateProvider<Song> SongProvider = StateProvider<Song>((ref) => Song());
// 再生時間を管理
final StateProvider<Duration> PositionProvider = StateProvider<Duration>((ref) => const Duration());
// 再生中の歌詞データを管理
final StateProvider<List<String>> LyricProvider = StateProvider<List<String>>(((ref) => [""]));
// 下タブのコントローラー
final PersistentTabController ptc = PersistentTabController();
// 再生リスト・再生リストのインデックス・プレイヤーの状態を管理
final StateProvider<MyAudioSource> AudioProvider = StateProvider<MyAudioSource>(((ref) => MyAudioSource()));
// 歌詞編集用SongModel
final StateProvider<Song> EditSongProvider = StateProvider<Song>((ref) => Song());
// 歌詞編集用AudioPlayer
final StateProvider<AudioPlayer> EditAPProvider = StateProvider<AudioPlayer>((ref) => AudioPlayer());
// 歌詞編集用再生時間
final StateProvider<Duration> EditPosiProvider = StateProvider<Duration>((ref) => const Duration());
// 歌詞編集用歌詞データ
final StateProvider<List<String>> EditLrcProvider = StateProvider<List<String>>(((ref) => [""]));
// 歌詞編集用テキストコントローラー
TextEditingController tec = TextEditingController();
// スプラッシュ画面に表示する[歌詞, 曲名, アーティスト名]のリスト
List<String> SplashTextList = ['', '', ''];
