import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

void setFuriganaAll(List<SongModel> songModelList) async {
  // gooひらがな化APIのリクエストURLとappIDを設定
  String apiUrl = 'https://labs.goo.ne.jp/api/hiragana';
  String appId = '9eb7aa7cd9680f9c2d8cb2d8422d980b175889f32a5fd73ac591c3e99f1e1545';

  // インスタンス生成
  final prefs = await SharedPreferences.getInstance();
  // 曲のフリガナを保持するString
  String? furigana;

  for (int i = 0; i < songModelList.length; i++) {
    // タイトルのフリガナを持ってくる
    furigana = prefs.getString(songModelList[i].title);
    // フリガナが保存されていなければ
    if (furigana == null) {
      // タイトルの一文字目が日本語なら
      if (containJapanese(songModelList[i].title[0]) == true) {
        // APIに変換をリクエスト
        var response = await http.post(
          Uri.parse(apiUrl),
          body: {
            'app_id': appId,
            'sentence': songModelList[i].title,
            'output_type': 'katakana',
          },
        );

        // 実行結果を受け取る
        var result = json.decode(response.body);
        // 無駄な空白は削除しフリガナ完成
        furigana = (result['converted'].toString()).replaceAll(RegExp(r'\s'), '');
      } else {
        // タイトルの一文字目が英語や数字なら
        // タイトルをそのままフリガナとする
        furigana = songModelList[i].title;
      }

      // フリガナの保存
      prefs.setString(songModelList[i].title, furigana);
    }
  }
}

// 日本語を含むかチェックする関数
bool containJapanese(String text) {
  return RegExp(r'[\u3040-\u309F]|\u3000|[\u30A1-\u30FC]|[\u4E00-\u9FFF]').hasMatch(text);
}
