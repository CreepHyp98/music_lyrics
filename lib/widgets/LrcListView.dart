import 'package:flutter/material.dart';
import 'package:music_lyrics/provider/provider.dart';

class LrcListView extends StatelessWidget {
  final String? lrcData;
  const LrcListView({super.key, this.lrcData});

  @override
  Widget build(BuildContext context) {
    List<String> splitLrcData = lrcData!.split('\n');

    return SizedBox(
      width: deviceWidth * 0.9,
      child: ListView.separated(
        // .lrcの末尾は空行なのでその分-1
        itemCount: splitLrcData.length - 1,
        itemBuilder: (context, index) {
          return ListTile(
            // ListTileの設定
            shape: RoundedRectangleBorder(
              side: const BorderSide(),
              borderRadius: BorderRadius.circular(5.0),
            ),
            // leadingとtitleの幅
            horizontalTitleGap: 5,
            // ListTile両端の余白
            contentPadding: const EdgeInsets.symmetric(horizontal: 5),

            // 左側タップで歌いだし時間の取得
            leading: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(
                    Icons.timer_outlined,
                  ),
                  // 歌いだし時間の表示
                  Text(splitLrcData[index].substring(2, 9)),
                ],
              ),
              onTap: () {},
            ),

            // 中央タップでダイアログ表示
            title: GestureDetector(
              child: SizedBox(
                height: 48.0,
                child: Text(
                  splitLrcData[index].substring(10),
                  maxLines: 2,
                ),
              ),
            ),

            // 右タップでそこから再生
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {},
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(
            height: 10.0,
          );
        },
      ),
    );
  }
}
