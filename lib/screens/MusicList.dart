import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:music_lyrics/class/SongClass.dart';
import 'package:music_lyrics/widgets/SongInfoDialog.dart';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:music_lyrics/provider/provider.dart';

class MusicList extends ConsumerStatefulWidget {
  final List<Song> PlayList;
  final bool dispArtist;
  final ScrollController? sc;

  // 定数コンストラクタ
  const MusicList({super.key, required this.PlayList, required this.dispArtist, this.sc});

  // stateの作成
  @override
  ConsumerState<MusicList> createState() => _MusicListState();
}

class _MusicListState extends ConsumerState<MusicList> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void playSong() {
    // SongProviderを更新
    int currentIndex = ref.watch(IndexProvider);
    ref.read(SongProvider.notifier).state = widget.PlayList[currentIndex];
    // LyricProviderを更新
    if (widget.PlayList[currentIndex].lyric != null) {
      ref.read(LyricProvider.notifier).state = widget.PlayList[currentIndex].lyric!.split('\n');
    } else {
      ref.read(LyricProvider.notifier).state = [''];
    }
    // 再生
    if (Platform.isAndroid == true) {
      audioPlayer.play(DeviceFileSource(ref.watch(SongProvider).path!));
    } else {
      audioPlayer.play(UrlSource(ref.watch(SongProvider).path!));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scrollbar(
      controller: widget.sc,
      thickness: 12.0,
      radius: const Radius.circular(12.0),
      interactive: true,
      child: ListView.builder(
        controller: widget.sc,
        // Listの要素数
        itemCount: widget.PlayList.length,
        // Listの生成
        itemBuilder: (context, index) {
          return ListTile(
            tileColor: const Color(0xfffffbfe),
            onTap: () {
              // 再生キュー
              SongQueue = widget.PlayList;
              // リストインデックス更新
              ref.read(IndexProvider.notifier).state = index;

              // 再生
              playSong();

              // NowPlayingに遷移
              lowerTC.jumpToTab(1);
            },
            title: Text(
              widget.PlayList[index].title!,
              maxLines: 1,
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: deviceWidth - 150,
                  child: Text(
                    // アーティスト名かアルバム名か表示を分ける
                    widget.dispArtist ? "${widget.PlayList[index].artist}" : "${widget.PlayList[index].album}",
                    maxLines: 1,
                  ),
                ),
                Text(IntDurationToMS(widget.PlayList[index].duration)),
              ],
            ),
            trailing: IconButton(
              onPressed: () {
                // 歌詞編集用SongModelに今開いてる曲をセット
                ref.read(EditSongProvider.notifier).state = widget.PlayList[index];
                // EditLrcProviderを更新
                if (widget.PlayList[index].lyric != null) {
                  ref.read(EditLrcProvider.notifier).state = widget.PlayList[index].lyric!.split('\n');
                } else {
                  ref.read(EditLrcProvider.notifier).state = [''];
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
              id: widget.PlayList[index].id!,
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

String IntDurationToMS(int? time) {
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
