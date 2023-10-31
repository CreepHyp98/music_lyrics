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
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('いいえ'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                // データベースから削除
                songsDB.instance.deleteSong(ref.watch(EditSongProvider).id!);
                // 遷移元の画面を破棄してホーム画面へ
                Navigator.of(context).pushReplacementNamed("/home");
              },
              child: const Text(
                ' はい ',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
