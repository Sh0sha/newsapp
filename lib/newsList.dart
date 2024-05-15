import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newsapp/func.dart';
import 'package:newsapp/main.dart';
import 'package:newsapp/newsDetail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newsapp/recentNews.dart';


// Список новостей
class NewsList extends StatefulWidget {
  final List<News> newsList;

  NewsList({required this.newsList});

  @override
  _NewsListState createState() => _NewsListState();
}


class _NewsListState extends State<NewsList> {
  DateTimeRange? _selectDatePeriod;
  String? _selectTag;
  bool _ascending = true; // направление сотрировки

  @override
  Widget build(BuildContext context) {
    List<News> filteredNewsList = widget.newsList;
    filteredNewsList = _NewsClientState()
        .filtNewsPeriod(filteredNewsList, _selectDatePeriod, _selectTag); // фильтр
    filteredNewsList =
        _NewsClientState().sortNews(filteredNewsList, _ascending); // Сортировка

    return Column(
      children: [
        // штучки управления для фильтрации и сортировки
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _selectDatePeriod = null;
                  _selectTag = null;
                });
              },
              icon: Icon(Icons.replay_sharp), // Иконка сброса
            ),
            DropdownButton<String>(
              // ВЫПАД. МЕНЮ
              alignment: Alignment.center,
              iconSize: 25,
              value: _selectTag,
              hint: Text('Тег'),
              borderRadius: BorderRadius.circular(25),
              items:
              ['Общество', 'Экономика', 'Спорт', 'Наука'].map((String tag) {
                return DropdownMenuItem<String>(
                  value: tag,
                  child: Text(tag),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectTag = newValue;
                });
              },
            ),

            // Дата выпадающий список
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              onPressed: () {
                showDateRangePicker( context: context, firstDate: DateTime(2000), lastDate: DateTime.now(),)
                    .then((dateRange)
                {
                  if (dateRange != null) {
                    setState(() {
                      _selectDatePeriod = dateRange;
                    });
                  }
                }
                );
              },
              child:FittedBox(   // автоматически масштабирует Text, уменьшает шрифт
                fit: BoxFit.scaleDown,
                child: Text(

                  _selectDatePeriod != null
                      ? '${DateFormat.yMd().format(_selectDatePeriod!.start)} - ${DateFormat.yMd().format(_selectDatePeriod!.end)}'
                      : 'Дата',
                  style: TextStyle(fontWeight: FontWeight.w500,color: Colors.black),
                ),
              ),



            ),

            IconButton(     // Кнопка сортировки по дате
              onPressed: () {
                setState(() {
                  _ascending = !_ascending; // свич направления сортировки
                });
              },
              icon: Icon(_ascending
                  ? Icons.arrow_upward
                  : Icons.arrow_downward), // иконки сортировки при нажатии
            ),
          ],
        ),

        Expanded(         // для прокрутки вниз списка новостей
          child: ListView.builder(    // списк новостей
            itemCount: filteredNewsList.length,
            itemBuilder: (context, index) {
              final news = filteredNewsList[index];
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12), // цвет и толщина границы
                  borderRadius: BorderRadius.all(Radius.circular(10)), // закругленные углы
                ),
                padding: EdgeInsets.all(2), // отступы внутри контейнера
                margin: EdgeInsets.symmetric(vertical: 3, horizontal: 3), // отступы между контейнерами

                child: ListTile(
                  title: Text(news.title),
                  subtitle: Text('${DateFormat.yMMMd().format(news.date)}  |  ${news.tag}'), // Форматируем дату без времени
                  leading: CachedNetworkImage(      // для сохранения изобр в памяти телефона
                    imageUrl: news.imageUrl,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                    height: 110,
                    width: 110,
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
          ),



        ),
      ],
    );
  }
}




class NewsClient extends StatefulWidget {
  @override
  _NewsClientState createState() => _NewsClientState();
}

// Главный экран + функции
class _NewsClientState extends State<NewsClient> {
  late List<News> _newsList;
  late Future<List<News>> _futureList;
  late NewsStorage _newsStorage;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _newsStorage = NewsStorage();
    _futureList = getNews();
  }

  Future<List<News>> getNews() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        _isOffline = true;
        return await _newsStorage.loadRecentNews();
      }

      final response = await http.get(
        Uri.parse(
            'https://uvlfpiijmtcpjdunxiwg.supabase.co/rest/v1/news?select=*'),
        headers: {
          'apikey':
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV2bGZwaWlqbXRjcGpkdW54aXdnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTM4OTY1MzMsImV4cCI6MjAyOTQ3MjUzM30.xlpxQBJhQhBHBoHeke-hE7CRamMYNmHXGz1dudDp25I',
        }, // апи ключ
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        final List<News> newsList = responseData.map((json) => News.fromJson(json)).toList();
        await _newsStorage.saveRecentNews(newsList); // Сохранение новостей при успешной загрузке
        _isOffline = false;
        return newsList;
      } else {
        throw Exception("Ошибка, сервер не работает");
      }
    } catch (e) {   // Возвращаем сохраненные новости при ошибке сети
      _isOffline = true;
      // Возвращаем сохраненные новости при ошибке сети
      return await _newsStorage.loadRecentNews();
    }
  }

// фильтр новостей по периоду дат
  List<News> filtNewsPeriod(List<News> newsList, DateTimeRange? selectedDateRange, String? selectedTag) {
    if (selectedDateRange != null) {
      newsList = newsList.where((news) =>
      selectedDateRange.start.isBefore(news.date) && selectedDateRange.end.isAfter(news.date)).toList();
    }
    if (selectedTag != null && selectedTag.isNotEmpty) {
      newsList = newsList.where((news) => news.tag == selectedTag).toList();
    }
    return newsList;
  }

// функция  для сортировки новостей по дате
  List<News> sortNews(List<News> newsList, bool ascending) {
    newsList.sort((a, b) =>
    ascending ? a.date.compareTo(b.date) : b.date.compareTo(a.date));
    return newsList;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Новости'), backgroundColor: Colors.green[300],
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecentNewsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body:  FutureBuilder<List<News>>(
        future: _futureList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            _newsList = snapshot.data!;
            return Column(
              children: [
                if (_isOffline) ...[
                  Container(
                    color: Colors.red,
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning, color: Colors.white),
                        SizedBox(width: 8),
                        Text( textAlign: TextAlign.center,
                          'Нет подключения к интернету',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
                Expanded(
                  child: NewsList(newsList: _newsList),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}


