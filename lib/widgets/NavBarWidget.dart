import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/screens/AllSongs.dart';
import 'package:music_lyrics/screens/NowPlaying.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

class NavBarWidget extends ConsumerWidget {
  const NavBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = [
      // 曲リスト画面
      const AllSongs(),
      // 再生画面
      const NowPlaying(),
    ];

    return Scaffold(
      body: PersistentTabView(
        context,
        controller: ptc,
        screens: pages,
        items: [
          // 1番目のタブ
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.queue_music),
            activeColorPrimary: Colors.black,
            inactiveColorPrimary: Colors.grey,
          ),
          // 2番目のタブ
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.play_circle),
            activeColorPrimary: Colors.black,
            inactiveColorPrimary: Colors.grey,
            onPressed: (p0) {
              if (ref.watch(SongProvider).title == null) {
                return null;
              } else {
                ptc.jumpToTab(1);
              }
            },
          ),
        ],
        navBarStyle: NavBarStyle.style3,
        backgroundColor: const Color(0xfffffbfe),
        // 画面遷移のアニメーション
        screenTransitionAnimation: const ScreenTransitionAnimation(
          animateTabTransition: true,
          curve: Curves.linear,
        ),
      ),
    );
  }
}
