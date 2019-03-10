import 'package:equatable/equatable.dart';
import 'package:darulfikr/model/article.dart';

abstract class ArticleState extends Equatable {
  ArticleState([List props = const []]) : super(props);
}

class ArticleUninitialized extends ArticleState {
  @override
  String toString() => 'ArticleUninitialized';
}

class ArticleError extends ArticleState {
  @override
  String toString() => 'ArticleError';
}

class ArticleLoaded extends ArticleState {
  final List<Article> articles;
  final bool hasReachedMax;

  ArticleLoaded({this.articles, this.hasReachedMax})
      : super([articles, hasReachedMax]);

  ArticleLoaded copyWith({List<Article> articles, bool hasReachedMax}) {
    return ArticleLoaded(
        articles: articles ?? this.articles,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax);
  }

  @override
  String toString() =>
      'ArticleLoaded { articles: ${articles.length}, hasReachedMax: $hasReachedMax }';
}
