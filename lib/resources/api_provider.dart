import 'package:darulfikr/utils/constants.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:darulfikr/model/article.dart';
import 'package:darulfikr/model/audio.dart';
import 'dart:convert';
import 'package:darulfikr/utils/other.dart';

final String url = 'http://$siteUrl/wp-json/wp/v2';
Future<List<Article>> fetchArticles(int page, int category) async {
  String apiUrl = '$url/posts?per_page=$page&categories=$category';
  final response = await http.get(apiUrl);

  return parseArticle(htmlEnescape(response.body));
}

Future<List<Article>> fetchRelatedPosts(String link) async {
  final response = await http.get(link);

  return parseArticle(htmlEnescape(response.body));
}

Future<String> fetchAudioImage(String link) async {
  var response = await http.get(link);
  var doc = parse(response.body);
  return doc
      .getElementsByClassName('cat_desc_img_audio cat_desc_img_audio_list')
      .first
      .children
      .first
      .attributes['src'];
}

Future<List<AudioCategory>> fetchAudioCategory({int parent}) async {
  String apiUrl = '$url/categories?parent=$parent';
  final response = await http.get(apiUrl);

  return parseAudioCategory(htmlEnescape(response.body));
}

Future<List<Article>> fetchSearch(String query) async {
  String apiUrl = '$url/posts?per_page=50&search=$query';
  final response = await http.get(apiUrl);
  return parseArticle(htmlEnescape(response.body));
}

Future<List<Article>> fetchTags(int category) async {
  String apiUrl = '$url/posts?per_page=10&tags=$category';
  final response = await http.get(apiUrl);
  return parseArticle(htmlEnescape(response.body));
}

List<Article> parseArticle(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Article>((json) => Article.fromJson(json)).toList();
}

List<AudioCategory> parseAudioCategory(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed
      .map<AudioCategory>((json) => AudioCategory.fromJson(json))
      .toList();
}
