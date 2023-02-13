import 'package:on_audio_query/on_audio_query.dart';
import 'package:riverpod/riverpod.dart';

// SongModelの状態を管理
final StateProvider<SongModel> SongModelProvider = StateProvider<SongModel>((ref) => SongModel({}));
// 再生位置の状態を管理
final StateProvider<Duration> PositionProvider = StateProvider<Duration>((ref) => const Duration());
