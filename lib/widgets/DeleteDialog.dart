import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_lyrics/provider/provider.dart';
import 'package:music_lyrics/class/SongDB.dart';

class DeleteDialog extends ConsumerWidget {
  const DeleteDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text(
        '本当に削除しますか？',
        style: TextStyle(fontSize: 20),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Text(
                'キャンセル',
                style: TextStyle(fontSize: 15),
              ),
            ),
            GestureDetector(
              onTap: () {
                // データベースから削除
                songsDB.instance.deleteSong(ref.watch(EditSongProvider).id!);
                // 遷移元の画面を破棄してホーム画面へ
                Navigator.of(context).pushReplacementNamed("/home");
              },
              child: Text(
                '削除する',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
