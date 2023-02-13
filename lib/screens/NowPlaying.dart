import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/widgets/VerticalRotatedWriting.dart';
import 'package:on_audio_query/on_audio_query.dart';

class NowPlaying extends ConsumerStatefulWidget {
  // 定数コンストラクタ
  final List<SongModel> songModelList;
  final int songIndex;
  final AudioPlayer audioPlayer;

  const NowPlaying({Key? key, required this.songModelList, required this.songIndex, required this.audioPlayer}) : super(key: key);

  // stateの作成
  @override
  ConsumerState<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends ConsumerState<NowPlaying> {
  // クラスのインスタンス化
  Duration _duration = const Duration();

  // 再生中かどうかのフラグをfalseで初期化
  bool _isPlaying = false;
  // 再生リストの初期化
  List<AudioSource> audioSourceList = [];
  // 現在再生中のindexを入れる変数を宣言
  int currentIndex = 0;

  // 初回表示時の処理
  @override
  void initState() {
    super.initState();
    currentIndex = widget.songIndex;
    // 曲の解析
    parseSong();
  }

  void parseSong() {
    try {
      // 受け取った曲リストを音源ファイルに変換し再生リストに加える
      for (var element in widget.songModelList) {
        audioSourceList.add(
          // URI文字列 → URIオブジェクト → 音源ファイル
          AudioSource.uri(
            Uri.parse(element.uri!),
            tag: MediaItem(
              id: element.id.toString(),
              title: element.title,
              artist: element.artist,
            ),
          ),
        );
      }

      // 再生リストをプレイヤーにセット
      widget.audioPlayer.setAudioSource(
        ConcatenatingAudioSource(children: audioSourceList),
        initialIndex: currentIndex,
      );

      // 再生
      widget.audioPlayer.play();
      // 再生中のフラグをオン
      _isPlaying = true;

      // 音源ファイルの曲時間を取得
      widget.audioPlayer.durationStream.listen((duration) {
        if (duration != null) {
          _duration = duration;
        }
      });
      // 現在の再生位置を取得
      widget.audioPlayer.positionStream.listen((position) {
        // このmountedがないとエラーになる
        if (mounted) {
          ref.read(PositionProvider.notifier).state = position;
        }
      });
      // これがないとメディア通知での操作が画面に反映されない
      listenToSongIndex();
    } on Exception catch (_) {
      // ページ遷移（戻る）
      Navigator.pop(context);
    }
  }

  void listenToSongIndex() {
    widget.audioPlayer.currentIndexStream.listen((event) {
      // このmountedがないとエラーになる
      if (mounted) {
        if (event != null) {
          currentIndex = event;
        }
        ref.read(SongModelProvider.notifier).state = widget.songModelList[currentIndex];
      }
    });
  }

  // widgetの生成
  @override
  Widget build(BuildContext context) {
    // 端末サイズからフォントサイズを指定
    double deviceWidth = MediaQuery.of(context).size.width;
    double fontSizeM = deviceWidth / 24.5;
    debugPrint("$deviceWidth, $fontSizeM");

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
              alignment: const Alignment(0.9, -0.5),
              child: VerticalRotatedWriting(
                size: fontSizeM,
                text: ref.watch(SongModelProvider).title,
              ),
            ),

            // アーティスト
            Align(
              alignment: const Alignment(0.7, 0.2),
              child: VerticalRotatedWriting(
                size: fontSizeM,
                text: ref.watch(SongModelProvider).artist.toString(),
              ),
            ),

            // 歌詞
            Align(
              child: VerticalRotatedWriting(
                size: fontSizeM,
                text: '歌詞サンプル',
              ),
            ),

            // 再生・停止ボタン
            Align(
              alignment: const Alignment(0.7, 0.98),
              child: IconButton(
                onPressed: () {
                  if (_isPlaying) {
                    widget.audioPlayer.pause();
                  } else {
                    widget.audioPlayer.play();
                  }
                  _isPlaying = !_isPlaying;
                  setState(() {});
                },
                icon: Icon(
                  _isPlaying ? Icons.pause_outlined : Icons.play_arrow_outlined,
                  size: fontSizeM,
                ),
              ),
            ),

            // 進むボタン
            Align(
              alignment: const Alignment(0.95, 0.98),
              child: IconButton(
                onPressed: () {
                  if (widget.audioPlayer.hasNext) {
                    widget.audioPlayer.seekToNext();
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

String DynamicDurationToMs(dynamic time) {
  String minutes = (time.toString().split(".")[0]).split(":")[1];
  String seconds = (time.toString().split(".")[0]).split(":")[2];

  return "$minutes:$seconds";
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
