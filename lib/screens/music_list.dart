import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:music_lyrics/class/song_class.dart';
import 'package:music_lyrics/widgets/song_info_dialog.dart';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:music_lyrics/provider/provider.dart';

class MusicList extends ConsumerStatefulWidget {
  final List<Song> playlist;
  final bool dispArtist;

  // 定数コンストラクタ
  const MusicList({super.key, required this.playlist, required this.dispArtist});

  // stateの作成
  @override
  ConsumerState<MusicList> createState() => _MusicListState();
}

class _MusicListState extends ConsumerState<MusicList> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void playSong() {
    // songProviderを更新
    int currentIndex = ref.watch(indexProvider);
    ref.read(songProvider.notifier).state = widget.playlist[currentIndex];
    // lyricProviderを更新
    if (widget.playlist[currentIndex].lyric != null) {
      ref.read(lyricProvider.notifier).state = widget.playlist[currentIndex].lyric!.split('\n');
    } else {
      ref.read(lyricProvider.notifier).state = [''];
    }
    // 再生
    if (Platform.isAndroid == true) {
      audioPlayer.play(DeviceFileSource(ref.watch(songProvider).path!));
    } else {
      audioPlayer.play(UrlSource(ref.watch(songProvider).path!));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scrollbar(
      thickness: 12.0,
      radius: const Radius.circular(12.0),
      interactive: true,
      child: ListView.builder(
        // Listの要素数
        itemCount: widget.playlist.length,
        // Listの生成
        itemBuilder: (context, index) {
          return ListTile(
            tileColor: const Color(0xfffffbfe),
            onTap: () {
              // 再生キュー
              songQueue = widget.playlist;
              // リストインデックス更新
              ref.read(indexProvider.notifier).state = index;

              // 再生
              playSong();

              // NowPlayingに遷移
              lowerTC.jumpToTab(1);
            },
            title: Text(
              widget.playlist[index].title!,
              maxLines: 1,
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: deviceWidth - 150,
                  child: Text(
                    // アーティスト名かアルバム名か表示を分ける
                    widget.dispArtist ? "${widget.playlist[index].artist}" : "${widget.playlist[index].album}",
                    maxLines: 1,
                  ),
                ),
                Text(intDurationToMinSec(widget.playlist[index].duration)),
              ],
            ),
            trailing: IconButton(
              onPressed: () {
                // 歌詞編集用SongModelに今開いてる曲をセット
                ref.read(editSongProvider.notifier).state = widget.playlist[index];
                // editLrcProviderを更新
                if (widget.playlist[index].lyric != null) {
                  editLrc = widget.playlist[index].lyric!.split('\n');
                } else {
                  editLrc = [''];
                }

                // ダイアログ表示
                showDialog(
                  context: context,
                  builder: (context) => const SongInfoDialog(),
                );
              },
              icon: const Icon(Icons.more_horiz),
            ),
            leading: QueryArtworkWidget(
              id: widget.playlist[index].id!,
              type: ArtworkType.AUDIO,
              artworkBorder: BorderRadius.circular(0),
              artworkFit: BoxFit.contain,
              nullArtworkWidget: const Icon(Icons.music_note),
            ),
            // leadingとtitleの幅
            horizontalTitleGap: 5,
            // ListTile両端の余白
            contentPadding: const EdgeInsets.symmetric(horizontal: 5),
          );
        },
      ),
    );
  }
}

String intDurationToMinSec(int? time) {
  String result;

  int minutes = (time! / (1000 * 60)).floor();
  int seconds = ((time / 1000) % 60).floor();

  if (seconds < 10) {
    result = "$minutes:0$seconds";
  } else {
    result = "$minutes:$seconds";
  }

  return result;
}
