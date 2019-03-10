import 'package:darulfikr/model/article.dart';

class SearchCache {
  final _cache = <String, List<Article>>{};

  List<Article> get(String term) => _cache[term];

  void set(String term, List<Article> result) => _cache[term] = result;

  bool contains(String term) => _cache.containsKey(term);

  void remove(String term) => _cache.remove(term);
}
