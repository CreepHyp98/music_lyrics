import 'package:flutter/material.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

// 全体タブのチュートリアル
List<TargetFocus> initTargets_1() {
  List<TargetFocus> targets = [];

  targets.add(
    TargetFocus(
      keyTarget: key[0],
      enableOverlayTab: true,
      contents: [
        TargetContent(
          padding: const EdgeInsets.only(left: 50, bottom: 50),
          child: const Text(
            "ここに歌詞を入力します",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        )
      ],
      shape: ShapeLightFocus.RRect,
      radius: 5,
    ),
  );

  targets.add(
    TargetFocus(
      keyTarget: key[1],
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: const Text(
            "歌詞の検索ができます",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        )
      ],
      shape: ShapeLightFocus.RRect,
      radius: 5,
    ),
  );

  targets.add(
    TargetFocus(
      keyTarget: key[2],
      enableOverlayTab: true,
      contents: [
        TargetContent(
          child: const Text(
            "入力が終わったら「同期」ボタンを\nタップします",
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ],
      shape: ShapeLightFocus.RRect,
      radius: 5,
    ),
  );

  return targets;
}

// 同期タブのチュートリアル
List<TargetFocus> initTargets_2() {
  List<TargetFocus> targets = [];
  targets.add(
    TargetFocus(
      keyTarget: key[3],
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: const Text(
            "歌詞を同期させるには\nまず曲を再生します",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        )
      ],
      shape: ShapeLightFocus.RRect,
      radius: 5,
    ),
  );

  targets.add(
    TargetFocus(
      keyTarget: key[4],
      enableOverlayTab: true,
      contents: [
        TargetContent(
          child: const Text(
            "歌い出しに合わせてタップします\nタップした時間がアイコンの下に\n表示されます",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        )
      ],
      shape: ShapeLightFocus.RRect,
      radius: 5,
    ),
  );

  targets.add(
    TargetFocus(
      keyTarget: key[5],
      enableOverlayTab: true,
      contents: [
        TargetContent(
          child: const Text(
            "同期した歌詞を保存します\n途中でも保存可能です",
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ],
      shape: ShapeLightFocus.RRect,
      radius: 5,
    ),
  );

  return targets;
}

void showTutorial(BuildContext context, int tutorialNum) {
  List<TargetFocus> targets = [];

  switch (tutorialNum) {
    case 1:
      targets = initTargets_1();
      break;
    case 2:
      targets = initTargets_2();
      break;
    default:
      debugPrint('ここに来たらエラー');
      break;
  }

  tcm = TutorialCoachMark(
    targets: targets,
    textSkip: "終了",
    paddingFocus: 10,
    opacityShadow: 0.8,
    onSkip: (() {
      if (tutorialNum == 1) {
        prefs.setBool('tutorial_1', false);
      } else {
        prefs.setBool('tutorial_2', false);
      }

      return true;
    }),
    onFinish: () {
      if (tutorialNum == 1) {
        prefs.setBool('tutorial_1', false);
      } else {
        prefs.setBool('tutorial_2', false);
      }
    },
  )..show(context: context);
}
