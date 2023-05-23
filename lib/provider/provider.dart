import 'package:music_lyrics/class/MyAudioSourceClass.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:riverpod/riverpod.dart';

// SongModelの状態を管理
final StateProvider<SongModel> SongModelProvider = StateProvider<SongModel>((ref) => SongModel({}));
// 再生時間を管理
final StateProvider<Duration> PositionProvider = StateProvider<Duration>((ref) => const Duration());
// 再生中の歌詞データを管理
final StateProvider<List<String>> LyricProvider = StateProvider<List<String>>(((ref) => [""]));
// 下タブのコントローラー
final PersistentTabController ptc = PersistentTabController();
// 再生リスト・再生リストのインデックス・プレイヤーの状態を管理
final StateProvider<MyAudioSource> AudioProvider = StateProvider<MyAudioSource>(((ref) => MyAudioSource()));
