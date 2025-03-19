import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'article_model.dart';

class NewsService {
  static final String theNewsApiKey = dotenv.get('THENEWS_API_KEY');
  static final String newsApiKey = dotenv.get('NEWS_API_KEY');

  static String getTheNewsApiUrl() {
    String publishedAfter = DateTime.now()
        .subtract(Duration(days: 1))
        .toUtc()
        .toString()
        .split(' ')[0];
    return 'https://api.thenewsapi.com/v1/news/top?api_token=$theNewsApiKey&locale=us,gb,ca&language=en&limit=10&published_after=$publishedAfter';
  }

  static String getNewsApiUrl() {
    return 'https://newsapi.org/v2/top-headlines?country=us&apiKey=$newsApiKey';
  }

  Future<List<Article>> fetchNews() async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse(getTheNewsApiUrl())),
        http.get(Uri.parse(getNewsApiUrl())),
      ]);

      List<Article> allArticles = [];

      for (var i = 0; i < responses.length; i++) {
        final response = responses[i];
        print('API ${i + 1} Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          Map<String, dynamic> data = json.decode(response.body);
          List<dynamic> articlesJson = [];

          // Handle different API response structures
          if (i == 0) {
            // The News API
            articlesJson = data['data'] ?? [];
          } else {
            // NewsAPI.org
            articlesJson = data['articles'] ?? [];
          }

          print('API ${i + 1} found ${articlesJson.length} articles');
          allArticles.addAll(
              articlesJson.map((json) => Article.fromJson(json)).toList());
        }
      }

      // Simple deduplication
      final uniqueUrls = <String>{};
      final filteredArticles = allArticles.where((article) {
        final isUnique = !uniqueUrls.contains(article.url);
        uniqueUrls.add(article.url);
        return isUnique;
      }).toList();

      print('Total unique articles after merge: ${filteredArticles.length}');
      return filteredArticles;
    } catch (e) {
      print('Fetch error: $e');
      throw Exception('Failed to load news: $e');
    }
  }
}
