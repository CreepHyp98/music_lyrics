import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_lyrics/provider/SongModelProvider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class NowPlaying extends StatefulWidget {
  // 定数コンストラクタ
  final List<SongModel> songModelList;
  final int songIndex;
  final AudioPlayer audioPlayer;

  const NowPlaying({Key? key, required this.songModelList, required this.songIndex, required this.audioPlayer}) : super(key: key);

  // stateの作成
  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  // クラスのインスタンス化
  Duration _duration = const Duration();
  Duration _position = const Duration();

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
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });
      listenToEvent();
      // 再生中の曲のidを取得
      listenToSongIndex();
    } on Exception catch (_) {
      // ページ遷移（戻る）
      Navigator.pop(context);
    }
  }

  void listenToEvent() {
    widget.audioPlayer.playerStateStream.listen((state) {
      if (state.playing) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
      }
    });
  }

  void listenToSongIndex() {
    widget.audioPlayer.currentIndexStream.listen((event) {
      if (mounted) {
        // このsetstateがないと通知タップから再生画面に飛ばない
        setState(() {
          if (event != null) {
            currentIndex = event;
          }
          context.read<SongModelProvider>().setId(widget.songModelList[currentIndex].id);
        });
      }
    });
  }

  // widgetの生成
  @override
  Widget build(BuildContext context) {
    // 端末サイズから高さを指定
    double width = MediaQuery.of(context).size.width;
    double sizedBoxM = width / 40;
    double fontSizeS = width / 30;
    double fontSizeM = width / 25;

    // OS側で出している上下のバーを避ける
    return SafeArea(
      // 画面を構成するUI構造
      child: Scaffold(
        // 子要素をカスタマイズするwidget
        body: Container(
          padding: const EdgeInsets.all(8.0),

          // 子要素を描画領域の最大サイズまで引き伸ばすwidget
          child: Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // アートワーク
                Card(
                  color: Theme.of(context).primaryColor,
                  child: const ArtworkWidget(),
                ),

                // 再生リストの現在地
                Text(
                  "$currentIndex / ${audioSourceList.length}",
                  style: TextStyle(
                    fontSize: fontSizeS,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: width / 13),

                // タイトル
                Text(
                  widget.songModelList[currentIndex].title,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: width / 20,
                  ),
                ),
                SizedBox(height: sizedBoxM),

                // アーティスト
                Text(
                  widget.songModelList[currentIndex].artist.toString(),
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: fontSizeM,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: sizedBoxM),

                // アルバム
                Text(
                  widget.songModelList[currentIndex].album.toString(),
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: fontSizeM,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: sizedBoxM),

                // 再生時間/スライダー/全体時間
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DynamicDurationToMs(_position),
                      style: TextStyle(
                        fontSize: fontSizeS,
                        color: Colors.grey[600],
                      ),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          inactiveTrackColor: Colors.grey[600],
                          activeTrackColor: Colors.black,
                          thumbColor: Colors.black,
                          trackHeight: 3,
                        ),
                        child: Slider(
                          min: 0.0,
                          value: _position.inSeconds.toDouble(),
                          max: _duration.inSeconds.toDouble(),
                          onChanged: (value) {
                            _position = Duration(seconds: value.toInt());
                            widget.audioPlayer.seek(_position);
                          },
                        ),
                      ),
                    ),
                    Text(
                      DynamicDurationToMs(_duration),
                      style: TextStyle(
                        fontSize: fontSizeS,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                // 戻る/再生・停止/進む
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (widget.audioPlayer.hasPrevious) {
                          widget.audioPlayer.seekToPrevious();
                        }
                      },
                      icon: const Icon(
                        Icons.skip_previous,
                        size: 24.0,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (_isPlaying) {
                          widget.audioPlayer.pause();
                        } else {
                          widget.audioPlayer.play();
                        }
                        _isPlaying = !_isPlaying;
                      },
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 24.0,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (widget.audioPlayer.hasNext) {
                          widget.audioPlayer.seekToNext();
                        }
                      },
                      icon: const Icon(
                        Icons.skip_next,
                        size: 24.0,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
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

class ArtworkWidget extends StatelessWidget {
  const ArtworkWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 端末サイズから高さを指定
    double width = MediaQuery.of(context).size.width;

    return QueryArtworkWidget(
      id: context.watch<SongModelProvider>().id,
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
