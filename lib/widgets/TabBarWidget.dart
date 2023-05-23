import 'package:flutter/material.dart';
import 'package:music_lyrics/screens/AllSongs.dart';

class TabBarWidget extends StatelessWidget {
  const TabBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      // タブ数
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            // flexibleSpaceでタイトルのスペースを削除
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                TabBar(
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(icon: Icon(Icons.music_note)),
                    Tab(icon: Icon(Icons.album)),
                    Tab(icon: Icon(Icons.person)),
                  ],
                )
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              // タブを移動してもstateが保存されているためにPageStorageKeyを渡す
              AllSongs(),
              Center(child: Text('アルバム')),
              Center(child: Text('アーティスト')),
            ],
          )),
    );
  }
}
