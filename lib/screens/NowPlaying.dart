import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/widgets/LyricWidget.dart';
import 'package:music_lyrics/widgets/VerticalRotatedWriting.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audioplayers/audioplayers.dart';

class NowPlaying extends ConsumerStatefulWidget {
  const NowPlaying({super.key});

  // stateの作成
  @override
  ConsumerState<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends ConsumerState<NowPlaying> {
  // 再生中かどうかのフラグをtrueで初期化
  bool _isPlaying = true;

  void playSong() {
    // SongProviderを更新
    int currentIndex = ref.watch(IndexProvider);
    ref.read(SongProvider.notifier).state = SongList[currentIndex];
    // LyricProviderを更新
    if (SongList[currentIndex].lyric != null) {
      ref.read(LyricProvider.notifier).state = SongList[currentIndex].lyric!.split('\n');
    } else {
      ref.read(LyricProvider.notifier).state = [''];
    }
    // 再生
    if (Platform.isAndroid == true) {
      audioPlayer.play(DeviceFileSource(ref.watch(SongProvider).path!));
    } else {
      audioPlayer.play(UrlSource(ref.watch(SongProvider).path!));
    }
    _isPlaying = true;
  }

  void listenToSongStream() {
    // 現在の再生位置を取得
    audioPlayer.onPositionChanged.listen((position) {
      // このmountedがないとエラーになる
      if (mounted) {
        ref.read(PositionProvider.notifier).state = position;
      }
    });

    // 再生終了後
    audioPlayer.onPlayerComplete.listen((event) {
      _isPlaying = false;
      // このmountedがないとエラーになる
      if (mounted) {
        // 次のインデックスへ
        ref.read(IndexProvider.notifier).state = ref.watch(IndexProvider) + 1;

        // 再生
        playSong();
      }
    });
  }

  // widgetの生成
  @override
  Widget build(BuildContext context) {
    double fontSizeM = 18;
    double fontSizeL = 20;
    // 歌詞描画エリアのために端末高さサイズも取得
    double lyricAreaHeight = deviceHeight * 0.65;
    double lyricAreaWidth = deviceWidth * 0.525;

    // 再生状況の取得
    listenToSongStream();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // アルバム
            Align(
              alignment: const Alignment(-0.9, -0.95),
              child: Text(
                ref.watch(SongProvider).album.toString(),
                style: const TextStyle(
                  fontFamily: 'shippori3',
                ),
              ),
            ),

            // タイトル
            Align(
              alignment: const Alignment(0.85, -0.2),
              child: VerticalRotatedWriting(
                size: fontSizeL,
                text: ref.watch(SongProvider).title!,
              ),
            ),

            // アーティスト
            Align(
              alignment: const Alignment(0.6, 0.4),
              child: VerticalRotatedWriting(
                size: fontSizeM,
                text: ref.watch(SongProvider).artist.toString(),
              ),
            ),

            ref.watch(SongProvider).lyric != null
                // 歌詞が登録されてれば歌詞
                ? Positioned(
                    top: deviceHeight * 0.15,
                    left: 0,
                    child: Container(
                      alignment: Alignment.topRight,
                      height: lyricAreaHeight,
                      width: lyricAreaWidth,
                      child: const LyricWidget(),
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
                    setState(() {
                      audioPlayer.pause();
                    });
                  } else {
                    setState(() {
                      audioPlayer.resume();
                    });
                  }
                  _isPlaying = !_isPlaying;
                },
                icon: Icon(
                  _isPlaying ? Icons.pause_outlined : Icons.play_arrow_outlined,
                  size: fontSizeM,
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
                    int nextIndex = ref.watch(IndexProvider) + 1;
                    if (nextIndex < SongList.length) {
                      ref.read(IndexProvider.notifier).state = nextIndex;
                      // 再生
                      playSong();
                    }
                  });
                },
                icon: Icon(
                  Icons.skip_next_outlined,
                  size: fontSizeM,
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
      id: ref.watch(SongProvider).id!,
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
