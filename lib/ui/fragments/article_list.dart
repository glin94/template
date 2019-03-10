import 'package:darulfikr/ui/pages/detail_page.dart';
import 'package:darulfikr/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:darulfikr/bloc/article_bloc/article_bloc.dart';
import 'package:darulfikr/bloc/article_bloc/article_event.dart';
import 'package:darulfikr/bloc/article_bloc/article_state.dart';
import 'package:darulfikr/model/article.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:darulfikr/resources/repository.dart';
import 'package:darulfikr/utils/other.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

class ArticleList extends StatefulWidget {
  final int page;
  final int category;
  final GlobalKey<ScaffoldState> skey;

  const ArticleList({Key key, this.page, this.category, this.skey})
      : super(key: key);

  _ArticleListState createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  final _scrollController = ScrollController();
  ArticleBloc _articleBloc;
  final _scrollThreshold = 200.0;
  Completer<void> _refreshCompleter;
  _ArticleListState() {
    _scrollController.addListener(_onScroll);
  }
  @override
  void initState() {
    _refreshCompleter = Completer<void>();
    _articleBloc = ArticleBloc(
        httpClient: http.Client(),
        category: widget.category,
        page: widget.page);
    _articleBloc.dispatch(Fetch());
    super.initState();
  }

  @override
  void dispose() {
    _articleBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () {
          _articleBloc.dispatch(Refresh());
          return _refreshCompleter.future;
        },
        child: BlocBuilder(
          bloc: _articleBloc,
          builder: (c, state) {
            if (state is ArticleUninitialized) {
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                ),
              );
            }
            if (state is ArticleError) {
              return buildBadError();
            }
            if (state is ArticleLoaded) {
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();
              if (state.articles.isEmpty) {
                return Center(
                  child: Text('Нет статей'),
                );
              }
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(8),
                itemBuilder: (BuildContext context, int index) {
                  return index >= state.articles.length
                      ? BottomLoader()
                      : ArticleWidget(article: state.articles[index]);
                },
                itemCount: state.hasReachedMax
                    ? state.articles.length
                    : state.articles.length + 1,
                controller: _scrollController,
              );
            }
          },
        ));
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _articleBloc.dispatch(Fetch());
    }
  }
}

class ArticleListView extends StatelessWidget {
  final List<Article> listArticle;

  const ArticleListView({Key key, this.listArticle}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: listArticle.length,
        itemBuilder: (c, i) => ArticleWidget(
              article: listArticle[i],
            ),
      ),
    );
  }
}

class BottomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Center(
            heightFactor: 1.5,
            child: SizedBox(
                width: 33,
                height: 33,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                ))));
  }
}

class ArticleWidget extends StatefulWidget {
  final Article article;

  const ArticleWidget({Key key, @required this.article}) : super(key: key);

  @override
  ArticleWidgetState createState() {
    return new ArticleWidgetState();
  }
}

class ArticleWidgetState extends State<ArticleWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
