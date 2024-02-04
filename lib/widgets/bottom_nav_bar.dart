import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/screens/main_page.dart';
import 'package:music_lyrics/screens/now_playing.dart';
import 'package:music_lyrics/screens/settings.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = [
      // 曲リスト画面
      const MainPage(),
      // 再生画面
      const NowPlaying(),
      // 設定画面
      const Settings(),
    ];

    return Scaffold(
      body: PersistentTabView(
        context,
        controller: lowerTC,
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
              if (ref.watch(songProvider).title == null) {
                return null;
              } else {
                lowerTC.jumpToTab(1);
              }
            },
          ),
          // 3番目のタブ
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.settings),
            activeColorPrimary: Colors.black,
            inactiveColorPrimary: Colors.grey,
          ),
        ],
        navBarStyle: NavBarStyle.style5,

        // 画面遷移のアニメーション
        screenTransitionAnimation: const ScreenTransitionAnimation(
          animateTabTransition: true,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOutQuart,
        ),
      ),
    );
  }
}
