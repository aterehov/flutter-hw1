import 'dart:convert';

class NewsResponse {
  final String status;
  final int totalResults;
  final List articles;
  // final

  const NewsResponse({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsResponse.fromJson(String jsonstr) {
    Map<String, dynamic> parsed = jsonDecode(jsonstr);
    final String status = parsed['status'];
    final int totalResults = parsed['totalResults'];
    final List articles = parsed['articles'];

    return NewsResponse(
        status: status, totalResults: totalResults, articles: articles);
  }
}
