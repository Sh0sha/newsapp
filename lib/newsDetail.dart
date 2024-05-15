import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newsapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

// страница новости
class NewsDetailScreen extends StatelessWidget {
  final News news;

  NewsDetailScreen({required this.news});


  Future<void> saveOpenedNews(News news) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList('opened_news') ?? [];
    jsonList.add(jsonEncode(news.toJson()));
    await prefs.setStringList('opened_news', jsonList);
  }

  @override
  Widget build(BuildContext context) {
    saveOpenedNews(news); // Сохранение новости при открытии

    return Scaffold(
      appBar: AppBar(
        title: Text(news.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                news.title,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                '${DateFormat.yMMMd().format(news.date)} | ${news.tag}',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 15),
              Hero(
                tag: 'news_image_${news.id}',
                child: ClipRRect(
                  // Обрезаем изображение кругом
                  borderRadius: BorderRadius.circular(5.0),
                  child: CachedNetworkImage(      // для сохранения изобр в памяти телефона
                    imageUrl: news.imageUrl,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),

              SizedBox(height: 25),
              Text(
                textAlign: TextAlign.justify,
                news.content,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
