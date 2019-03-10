import 'package:shared_preferences/shared_preferences.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:darulfikr/bloc/article_bloc/article_event.dart';
import 'package:darulfikr/bloc/article_bloc/article_state.dart';
import 'dart:core';
import 'package:darulfikr/model/article.dart';
import 'package:darulfikr/resources/repository.dart';

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final http.Client httpClient;
  List<Article> articles;
  final int page;
  final int category;
  ArticleBloc({
    @required this.httpClient,
    @required this.category,
    @required this.page,
  });

  @override
  Stream<ArticleEvent> transform(Stream<ArticleEvent> events) {
    return (events as Observable<ArticleEvent>)
        .debounce(Duration(milliseconds: 500));
  }

  @override
  ArticleState get initialState => ArticleUninitialized();

  @override
  Stream<ArticleState> mapEventToState(
      ArticleState currentState, ArticleEvent event) async* {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> idList = ((prefs.getStringList(category.toString()) ?? []));
    int refreshTime = (prefs.getInt(page.toString() + "timeRef") ?? 0);
    if (event is Fetch && !_hasReachedMax(currentState)) {
      try {
        if (currentState is ArticleUninitialized) {
          if (idList.isEmpty ||
              refreshTime == 0 ||
              DateTime.now().difference(
                      DateTime.fromMillisecondsSinceEpoch(refreshTime)) >=
                  Duration(hours: 3)) {
            articles = await Repository.get().getArticles(page, category);
            updateArticles(articles, idList, prefs);
          } else {
            articles =
                await Repository.get().getArticlesIds(idList.reversed.toList());
            articles = articles.reversed
                .toList(); // статьи перемешиваю наоборот? потому что отображаются не с последнего
          }
          yield ArticleLoaded(articles: articles, hasReachedMax: false);
        }
        if (currentState is ArticleLoaded) {
          final list = await Repository.get()
              .getArticles(articles.length + page, category);
          updateArticles(list, idList, prefs);
          // print("list is ${list.length}");
          // print("currentState is ${currentState.articles.length}");

          articles = list;

          yield articles.isEmpty ||
                  articles.length == 100 ||
                  articles.length == currentState.articles.length
              ? currentState.copyWith(hasReachedMax: true)
              : ArticleLoaded(
                  articles: articles,
                  hasReachedMax: false,
                );
        }
      } catch (_) {
        yield ArticleError();
      }
    }
    if (event is Refresh) {
      try {
        final list = await Repository.get().getArticles(page, category);
        updateArticles(articles, idList, prefs);
        yield ArticleLoaded(articles: list, hasReachedMax: false);
      } catch (_) {
        yield currentState;
      }
    }
  }

  void updateArticles(
      List<Article> articles, List<String> idList, SharedPreferences prefs) {
    idList.clear();
    articles.forEach((f) {
      idList.add(f.id);
      Repository.get().updateArticle(f);
    });
    print(idList);
    prefs.setStringList(category.toString(), idList);
    prefs.setInt(
        page.toString() + "timeRef", DateTime.now().millisecondsSinceEpoch);
  }

  bool _hasReachedMax(ArticleState state) =>
      state is ArticleLoaded && state.hasReachedMax;
}
