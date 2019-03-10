import 'package:darulfikr/bloc/article_bloc/article_bloc.dart';
import 'package:darulfikr/bloc/article_bloc/article_event.dart';
import 'package:darulfikr/bloc/article_bloc/article_state.dart';
import 'package:darulfikr/ui/pages/books_page.dart';
import 'package:darulfikr/utils/other.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class HorizontalList extends StatefulWidget {
  final int category;
  final GlobalKey<ScaffoldState> sKey;
  const HorizontalList({Key key, this.category, this.sKey}) : super(key: key);
  _HorizontalListState createState() => _HorizontalListState();
}

class _HorizontalListState extends State<HorizontalList> {
  ArticleBloc _articleBloc;

  @override
  void initState() {
    _articleBloc = ArticleBloc(
      httpClient: http.Client(),
      category: widget.category,
      page: 100,
    );
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
    return BlocBuilder(
      bloc: _articleBloc,
      builder: (c, state) {
        if (state is ArticleUninitialized) {
          return Center(
            heightFactor: 4.5,
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
              child: Text('Произошла неизвестная ошибка'),
            );
          }
          return Container(
              height: 200,
              padding: EdgeInsets.symmetric(vertical: 20),
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: BookItem(book: state.articles[index]),
                    );
                  },
                  itemCount: state.articles.length));
        }
      },
    );
  }
}
