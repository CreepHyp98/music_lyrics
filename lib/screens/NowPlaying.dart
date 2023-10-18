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

  void listenToSongStream() {
    // 現在の再生位置を取得
    ref.watch(AudioProvider).audioPlayer!.onPositionChanged.listen((position) {
      // このmountedがないとエラーになる
      if (mounted) {
        ref.read(PositionProvider.notifier).state = position;
      }
    });

    ref.watch(AudioProvider).audioPlayer!.onPlayerComplete.listen((event) {
      // このmountedがないとエラーになる
      if (mounted) {
        // 次のインデックスへ
        ref.watch(AudioProvider).songIndex != ref.watch(AudioProvider).songIndex! + 1;

        ref.read(SongProvider.notifier).state = ref.watch(AudioProvider).songList![ref.watch(AudioProvider).songIndex!];

        // LyricProviderを更新
        if (ref.watch(SongProvider).lyric != null) {
          ref.read(LyricProvider.notifier).state = ref.watch(SongProvider).lyric!.split('\n');
        } else {
          ref.read(LyricProvider.notifier).state = [''];
        }
      }
    });
  }

  // 再生中か停止中か取得
  void listenToEvent() {
    ref.watch(AudioProvider).audioPlayer!.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        if (mounted) {
          setState(() {
            _isPlaying = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
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

    if (ref.watch(AudioProvider).audioPlayer != null) {
      // 再生状況の取得
      listenToSongStream();
      listenToEvent();
    }

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
                    ref.watch(AudioProvider).audioPlayer!.pause();
                  } else {
                    ref.watch(AudioProvider).audioPlayer!.play(UrlSource(ref.watch(SongProvider).path!));
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
                  ref.watch(AudioProvider).audioPlayer!.onPlayerComplete.listen((event) {
                    //ref.watch(AudioProvider).audioPlayer!.seekToNext();
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
