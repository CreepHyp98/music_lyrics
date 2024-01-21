import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/widgets/lyric_text.dart';
import 'package:music_lyrics/widgets/vertical_rotated_writing.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock/wakelock.dart';

class NowPlaying extends ConsumerStatefulWidget {
  const NowPlaying({super.key});

  // stateの作成
  @override
  ConsumerState<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends ConsumerState<NowPlaying> {
  // 再生中かどうかのフラグをtrueで初期化
  bool _isPlaying = false;
  // 終了後の処理を行ったかフラグ
  bool _isFinished = false;

  void playSong() {
    // 再生位置リセット
    ref.read(positionProvider.notifier).state = Duration.zero;
    // songProviderを更新
    int currentIndex = ref.watch(indexProvider);
    ref.read(songProvider.notifier).state = songQueue[currentIndex];
    // lyricProviderを更新
    if (songQueue[currentIndex].lyric != null) {
      ref.read(lyricProvider.notifier).state = songQueue[currentIndex].lyric!.split('\n');
    } else {
      ref.read(lyricProvider.notifier).state = [''];
    }
    // 再生
    if (Platform.isAndroid == true) {
      audioPlayer.play(DeviceFileSource(ref.watch(songProvider).path!));
    } else {
      audioPlayer.play(UrlSource(ref.watch(songProvider).path!));
    }
    _isPlaying = true;
  }

  void listenToSongStream() {
    // 現在の再生位置を取得
    audioPlayer.onPositionChanged.listen((position) {
      // このmountedがないとエラーになる
      if (mounted) {
        ref.read(positionProvider.notifier).state = position;
      }
    });

    // 再生終了後
    audioPlayer.onPlayerComplete.listen((event) {
      // なぜか二回通るのでフラグもチェック
      if (mounted && _isFinished == false) {
        // 次のインデックスへ
        int nextIndex = ref.watch(indexProvider) + 1;
        if (nextIndex < songQueue.length) {
          ref.read(indexProvider.notifier).state = nextIndex;
          // 再生
          playSong();
          _isFinished = true;
        }
      }
    });
  }

  // 再生中か停止中か取得
  void listenToEvent() {
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        if (mounted) {
          setState(() {
            _isPlaying = true;
            _isFinished = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            // 画面スリープ無効を解除
            Wakelock.disable();
          });
        }
      }
    });
  }

  // widgetの生成
  @override
  Widget build(BuildContext context) {
    // 歌詞描画エリアのために端末高さサイズも取得
    double lyricAreaHeight = deviceHeight * 0.68;
    double lyricAreaWidth = deviceWidth * 0.68;

    // 再生状況の取得
    listenToSongStream();
    listenToEvent();

    return Scaffold(
      backgroundColor: const Color(0xfffffbfe),
      body: SafeArea(
        child: Stack(
          children: [
            // アルバム
            Align(
              alignment: const Alignment(-0.9, -0.95),
              child: Text(
                ref.watch(songProvider).album.toString(),
                style: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'shippori3',
                ),
              ),
            ),

            // タイトル
            Align(
              alignment: const Alignment(0.85, -0.2),
              child: VerticalRotatedWriting(
                fontSize: 20,
                text: ref.watch(songProvider).title!,
              ),
            ),

            // アーティスト
            Align(
              alignment: const Alignment(0.6, 0.4),
              child: VerticalRotatedWriting(
                fontSize: 18,
                text: ref.watch(songProvider).artist.toString(),
              ),
            ),

            ref.watch(songProvider).lyric != null
                // 歌詞が登録されてれば歌詞
                ? Positioned(
                    top: deviceHeight * 0.12,
                    left: 0,
                    child: Container(
                      alignment: Alignment.topRight,
                      height: lyricAreaHeight,
                      width: lyricAreaWidth,
                      child: const LyricText(),
                    ),
                  )
                // なければジャケ写
                : const Align(
                    alignment: Alignment(-0.5, 0.0),
                    child: ArtworkWidget(),
                  ),

            // 再生・停止ボタン
            Align(
              alignment: const Alignment(0.65, 0.98),
              child: IconButton(
                onPressed: () {
                  if (_isPlaying) {
                    audioPlayer.pause();
                  } else {
                    audioPlayer.resume();
                  }
                  _isPlaying = !_isPlaying;
                },
                icon: Icon(
                  _isPlaying ? Icons.pause_outlined : Icons.play_arrow_outlined,
                  size: 18,
                ),
              ),
            ),

            // 進むボタン
            Align(
              alignment: const Alignment(0.9, 0.98),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    // 次のインデックスへ
                    int nextIndex = ref.watch(indexProvider) + 1;
                    if (nextIndex < songQueue.length) {
                      ref.read(indexProvider.notifier).state = nextIndex;
                      // 再生
                      playSong();
                    }
                  });
                },
                icon: const Icon(
                  Icons.skip_next_outlined,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArtworkWidget extends ConsumerWidget {
  const ArtworkWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return QueryArtworkWidget(
      id: ref.watch(songProvider).id!,
      format: ArtworkFormat.PNG,
      artworkQuality: FilterQuality.high,
      type: ArtworkType.AUDIO,
      artworkBorder: BorderRadius.circular(0),
      artworkHeight: deviceWidth / 1.7,
      artworkWidth: deviceWidth / 1.7,
      artworkFit: BoxFit.contain,
    );
  }
}
