import 'package:flutter/material.dart';
import 'package:newsapp/newsList.dart';

void main()  {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'news app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NewsClient(),
    );
  }
}

class News {
  final int id;
  final String title;
  final String content;
  final DateTime date;
  final String tag;
  final String imageUrl; // Добавляем поле imageUrl

  News({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.tag,
    required this.imageUrl, // Обновляем конструктор
  });


  factory News.fromJson(Map<String, dynamic> json) {      // получаем данные фв формате Json
    return News(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      date: DateTime.parse(json['date']),
      tag: json['tag'],
      imageUrl: json['image_url'], // Присваиваем imageUrl из JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'tag': tag,
      'image_url': imageUrl,
    };
  }
}





