import 'package:cached_network_image/cached_network_image.dart';
import 'package:darulfikr/ui/fragments/slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:darulfikr/bloc/article_bloc/article_bloc.dart';
import 'package:darulfikr/bloc/article_bloc/article_event.dart';
import 'package:darulfikr/bloc/article_bloc/article_state.dart';
import 'package:darulfikr/model/article.dart';
import 'package:darulfikr/utils/other.dart';

class Videos extends StatefulWidget {
  final int page;
  final int category;

  const Videos({Key key, this.page, this.category}) : super(key: key);
  _VideosState createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  ArticleBloc _articleBloc;
  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  @override
  void initState() {
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
    return Scaffold(
        key: _key,
        body: BlocBuilder(
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
                if (state.articles.isEmpty) {
                  return Center(
                    child: Text('Нет видео'),
                  );
                }
                return Container(
                    child: Scrollbar(
                        child: CustomScrollView(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  slivers: <Widget>[],
                )));
              }
            }));
  }
}
