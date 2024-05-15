import 'dart:convert';
import 'package:newsapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';


// функции для сохранения и загрузки новостей в shared_preferences
class NewsStorage {
  static const String _keyRecentNews = 'recent_news';

  Future<void> saveRecentNews(List<News> newsList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList = newsList.map((news) => jsonEncode(news.toJson())).toList();
    await prefs.setStringList(_keyRecentNews, jsonList);
  }

  Future<List<News>> loadRecentNews() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList(_keyRecentNews);
    if (jsonList != null) {
      return jsonList.map((jsonString) => News.fromJson(jsonDecode(jsonString))).toList();
    } else {
      return [];
    }
  }
}

// фильтр  новостей по дате и тегу
// фильтр  новостей по дате и тегу
// List<News> filterNews(
//     List<News> newsList, DateTime? selectedDate, String? selectedTag) {
//   if (selectedDate != null) {
//     newsList = newsList
//         .where((news) => news.date.isAtSameMomentAs(selectedDate))
//         .toList();
//   }
//   if (selectedTag != null && selectedTag.isNotEmpty) {
//     newsList = newsList.where((news) => news.tag == selectedTag).toList();
//   }
//   return newsList;
// }  фильтр  новостей по дате и тегу
