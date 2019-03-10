import 'package:shared_preferences/shared_preferences.dart';
import 'package:darulfikr/bloc/search_bloc/search_cache.dart';
import 'package:darulfikr/model/article.dart';
import 'package:darulfikr/model/audio.dart';
import 'package:darulfikr/resources/api_provider.dart';
import 'dart:async';
import 'package:darulfikr/resources/article_database.dart';

class Repository {
  static final Repository _repo = Repository._internal();
  ArticleDataBase database;
  static Repository get() {
    return _repo;
  }

  Repository._internal() {
    database = ArticleDataBase();
  }

  Future<List<Article>> getArticles(int page, int category) async {
    return await fetchArticles(page, category);
  }

  Future<List<Article>> getArticlesbyTags(int category) async {
    return await fetchTags(category);
  }

  Future<List<AudioCategory>> getAudio(int parent) async {
    return await fetchAudioCategory(parent: parent);
  }

  Future<String> getAudioImage(String link) async {
    return await fetchAudioImage(link);
  }

  Future<List<Article>> getRelatedPosts(String link) async {
    return await fetchRelatedPosts(link);
  }

  Future<List<Article>> getArticlesDB(String key, dynamic value) async {
    return database.getArticles(key, value);
  }

  Future<List<Article>> getFavoriteArticlesFromDB(String column) async {
    switch (column) {
      case "":
        return await database.getFavoriteArticles();
        break;
      case "video":
        return await database.getNotEmptyFavoriteColumn(column);
      case "book":
        return await database.getNotEmptyFavoriteColumn(column);
      default:
        return null;
    }
  }

  Future<List<Article>> getArticlesIds(List<String> list) async {
    return database.getArticlesWithIds(list);
  }

  Future updateArticle(Article book) async {
    database.updateArticle(book);
  }

  Future close() async {
    return database.closeDB();
  }
}

class SearchRepository {
  final SearchCache cache;

  SearchRepository(this.cache);

  Future<List<Article>> search(String term) async {
    if (cache.contains(term)) {
      return cache.get(term);
    } else {
      final result = await fetchSearch(term);
      cache.set(term, result);
      return result;
    }
  }

  Future<List<String>> getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> list = List();
    list = (prefs.getStringList("searchList") ?? []);
    return list;
  }

  delPrefList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> list = List();
    list = (prefs.getStringList("searchList") ?? []);
    list.clear();
    prefs.setStringList('searchList', list);
    return list;
  }

  Future<List<String>> setPref(String searchTerm) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> list = (prefs.getStringList("searchList") ?? []);
    list.removeWhere((s) => s == searchTerm);
    list.add(searchTerm);
    prefs.setStringList('searchList', list);
    return list;
  }
}
