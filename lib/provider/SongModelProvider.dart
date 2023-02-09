import 'package:riverpod/riverpod.dart';

// SongModelのidを管理
final SongModelProvider = StateProvider((ref) => 0);
// 再生位置の状態を管理
final StateProvider<Duration> PositionProvider = StateProvider<Duration>((ref) => const Duration());
