import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/widgets/LyricWidget.dart';
import 'package:music_lyrics/widgets/VerticalRotatedWriting.dart';
import 'package:on_audio_query/on_audio_query.dart';

class NowPlaying extends ConsumerStatefulWidget {
  const NowPlaying({super.key});

  // stateの作成
  @override
  ConsumerState<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends ConsumerState<NowPlaying> {
  // クラスのインスタンス化
  Duration _duration = const Duration();

  // 再生中かどうかのフラグをfalseで初期化
  bool _isPlaying = false;

  void listenToSongStream() {
    // 音源ファイルの曲時間を取得
    ref.watch(AudioProvider).audioPlayer!.durationStream.listen((duration) {
      if (duration != null) {
        _duration = duration;
      }
    });

    // 現在の再生位置を取得
    ref.watch(AudioProvider).audioPlayer!.positionStream.listen((position) {
      // このmountedがないとエラーになる
      if (mounted) {
        ref.read(PositionProvider.notifier).state = position;
      }
    });

    ref.watch(AudioProvider).audioPlayer!.currentIndexStream.listen((event) {
      // このmountedがないとエラーになる
      if (mounted) {
        if (event != null) {
          ref.watch(AudioProvider).songIndex = event;
        }
        ref.read(SongModelProvider.notifier).state = ref.watch(AudioProvider).songModelList![ref.watch(AudioProvider).songIndex!];
      }
    });
  }

  // 再生中か停止中か取得
  void listenToEvent() {
    ref.watch(AudioProvider).audioPlayer!.playerStateStream.listen((state) {
      if (state.playing) {
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
    // 端末幅サイズからフォントサイズを指定
    double deviceWidth = MediaQuery.of(context).size.width;
    double fontSizeM = 18; //deviceWidth / 21.8; //18pt
    double fontSizeL = 20; //deviceWidth / 19.6; //20pt
    // 歌詞描画エリアのために端末高さサイズも取得
    double deviceHeight = MediaQuery.of(context).size.height;
    double lyricAreaHeight = deviceHeight * 0.65;
    double lyricAreaWidth = deviceWidth * 0.525;

    // これがないとメディア通知での操作が画面に反映されない
    listenToSongStream();
    // 再生状況の取得
    listenToEvent();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // アルバム
            Align(
              alignment: const Alignment(-0.9, -0.95),
              child: Text(
                ref.watch(SongModelProvider).album.toString(),
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
                text: ref.watch(SongModelProvider).title,
              ),
            ),

            // アーティスト
            Align(
              alignment: const Alignment(0.6, 0.4),
              child: VerticalRotatedWriting(
                size: fontSizeM,
                text: ref.watch(SongModelProvider).artist.toString(),
              ),
            ),

            // 歌詞
            Positioned(
              top: deviceHeight * 0.15,
              left: 0,
              child: Container(
                alignment: Alignment.topRight,
                height: lyricAreaHeight,
                width: lyricAreaWidth,
                child: const LyricWidget(),
              ),
            ),

            // 再生・停止ボタン
            Align(
              alignment: const Alignment(0.65, 0.98),
              child: IconButton(
                onPressed: () {
                  if (_isPlaying) {
                    ref.watch(AudioProvider).audioPlayer!.pause();
                  } else {
                    ref.watch(AudioProvider).audioPlayer!.play();
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
                  if (ref.watch(AudioProvider).audioPlayer!.hasNext) {
                    ref.watch(AudioProvider).audioPlayer!.seekToNext();
                  }
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
    // 端末サイズから高さを指定
    double width = MediaQuery.of(context).size.width;

    return QueryArtworkWidget(
      id: ref.watch(SongModelProvider).id,
      format: ArtworkFormat.PNG,
      artworkQuality: FilterQuality.high,
      type: ArtworkType.AUDIO,
      artworkBorder: BorderRadius.circular(0),
      artworkHeight: width / 1.3,
      artworkWidth: width / 1.3,
      artworkFit: BoxFit.contain,
      nullArtworkWidget: Icon(
        Icons.music_note,
        size: width / 1.3,
      ),
    );
  }
}
