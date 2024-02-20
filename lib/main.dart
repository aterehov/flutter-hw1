import 'dart:async';

import 'package:todaynews/news_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart';

import 'app_theme.dart';
import 'error_handler.dart';
import 'logger.dart';
import 's.dart';

void main() {
  runZonedGuarded(() {
    initLogger();
    logger.info('Start main');

    ErrorHandler.init();
    runApp(const App());
  }, ErrorHandler.recordError);
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  var _isDark = false;
  var _locale = S.en;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.supportedLocales,
      locale: _locale,
      builder: (context, child) => Material(
        child: Stack(
          children: [
            child ?? const SizedBox.shrink(),
            Align(
              alignment: Alignment.topLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: IconButton(
                      onPressed: () {
                        final newMode = !_isDark;
                        logger.info(
                          'Switch theme mode: '
                          '${_isDark.asThemeName} -> ${newMode.asThemeName}',
                        );
                        setState(() => _isDark = newMode);
                      },
                      icon: Icon(
                        _isDark ? Icons.sunny : Icons.nightlight_round,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: InkResponse(
                      child: Text(_locale.languageCode.toUpperCase(),
                          style: const TextStyle(fontSize: 14)),
                      onTap: () {
                        final newLocale = S.isEn(_locale) ? S.ru : S.en;
                        logger.info(
                          'Switch language: '
                          '${_locale.languageCode} -> ${newLocale.languageCode}',
                        );
                        setState(() => _locale = newLocale);
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      theme: AppTheme.theme(_isDark),
      home: const HomePage(),
    );
  }
}

class HPState extends State<HomePage> {
  int page = 1;
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(border: Border.all()),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 64.0, 12.0, 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Последние новости',
                            style: TextStyle(fontSize: 32),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height: 650,
                              width: 365,
                              child: SingleChildScrollView(
                                  controller: controller,
                                  child: Column(children: [
                                    getNews(page: page),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          page = page + 1;
                                          controller.jumpTo(controller
                                              .position.minScrollExtent);
                                        });
                                      },
                                      child: const Text('Больше новостей'),
                                    )
                                  ])))
                        ],
                      )
                    ],
                  ),
                ],
              ),
            )));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() {
    return HPState();
  }
}

FutureBuilder getNews({int page = 1}) {
  return FutureBuilder<NewsResponse>(
      future: fetchNews(page: page),
      builder: (BuildContext context, AsyncSnapshot<NewsResponse> snapshot) {
        if (snapshot.hasData) {
          NewsResponse? data = snapshot.data;
          List<Widget> arts = [];
          for (var i = 0;
              i <
                  (page <= data!.totalResults / 100
                      ? 100
                      : data.totalResults % 100);
              i++) {
            arts.add(NewsCard(info: data.articles[i]));
          }

          return Column(
            children: arts,
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      });
}

Future<NewsResponse> fetchNews({int page = 1}) async {
  Response res = await get(Uri.parse(
      'https://newsapi.org/v2/everything?page=${page.toString()}&sources=abc-news,the-huffington-post,bloomberg,reddit-r-all,lequipe,al-jazeera-english,national-geographic,bleacher-report,svenska-dagbladet,engadget,wirtschafts,new-york-magazine,football-italia,spiegel-online,le-monde,rtl-nieuws,usa-today,google-news-ar,national-review,axios&apiKey=85664fb2ca34468f9f24112b22031653'));

  var ret = NewsResponse.fromJson(res.body);
  return ret;
}

class NewsCard extends StatelessWidget {
  final Map<String, dynamic> info;

  const NewsCard({
    super.key,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          info['urlToImage'] != null
              ? Image.network(
                  info['urlToImage'],
                  width: 100.0,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return const SizedBox(
                        width: 100, child: Text('Failed to load image'));
                  },
                )
              : const SizedBox(width: 100, child: Text('Image unavailable')),
          SizedBox(
              width: 256,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info['publishedAt']),
                  Text(
                    info['title'],
                    style: const TextStyle(fontSize: 24),
                    // softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  Text("Источник: ${info['source']['name']}"),
                  Text("Автор: ${info['author']}"),
                  Text(info['description'] ?? '')
                ],
              ))
        ],
      ),
    );
  }
}

extension _BoolToThemeName on bool {
  String get asThemeName => this ? 'dark' : 'light';
}
