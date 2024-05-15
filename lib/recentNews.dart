import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newsapp/func.dart';
import 'package:newsapp/main.dart';
import 'package:newsapp/newsDetail.dart';


// экран для отображения последних открытых новостей
class RecentNewsScreen extends StatelessWidget {
  final NewsStorage newsStorage = NewsStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Последние открытые новости'),
      ),
      body: FutureBuilder<List<News>>(
        future: newsStorage.loadRecentNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('error: ${snapshot.error}'));
          } else {
            List<News> newsList = snapshot.data ?? [];
            return ListView.builder(
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                final news = newsList[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    title: Text(news.title),
                    subtitle: Text('${DateFormat.yMMMd().format(news.date)} | ${news.tag}'),
                    leading: CachedNetworkImage(      // для сохранения изобр в памяти телефона
                      imageUrl: news.imageUrl,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsDetailScreen(news: news),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}