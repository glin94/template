import 'package:cached_network_image/cached_network_image.dart';
import 'package:darulfikr/ui/pages/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:darulfikr/bloc/article_bloc/article_bloc.dart';
import 'package:darulfikr/bloc/article_bloc/article_event.dart';
import 'package:darulfikr/bloc/article_bloc/article_state.dart';
import 'package:darulfikr/model/article.dart';
import 'package:http/http.dart' as http;
import 'package:darulfikr/utils/other.dart';

class Books extends StatefulWidget {
  final int page;
  final int category;

  const Books({Key key, this.page, this.category}) : super(key: key);
  _BooksState createState() => _BooksState();
}

class _BooksState extends State<Books> {
  ArticleBloc _articleBloc;
  GlobalKey<ScaffoldState> _skey = GlobalKey<ScaffoldState>();
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
        key: _skey,
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
                    child: Text('Нет книг'),
                  );
                }
                return Container(
                    child: Scrollbar(
                        child: CustomScrollView(
                  primary: false,
                  slivers: <Widget>[
                    SliverPadding(
                      padding: EdgeInsets.all(16.0),
                      sliver: SliverGrid.count(
                        childAspectRatio: 2 / 3,
                        crossAxisCount: 3,
                        mainAxisSpacing: 20.0,
                        crossAxisSpacing: 20.0,
                        children: state.articles
                            .map((f) => BookItem(
                                  book: f,
                                  skey: _skey,
                                ))
                            .toList(),
                      ),
                    )
                  ],
                )));
              }
            }));
  }
}

class BookItem extends StatefulWidget {
  final Article book;
  final GlobalKey<ScaffoldState> skey;

  const BookItem({Key key, this.book, this.skey}) : super(key: key);

  @override
  BookItemState createState() {
    return new BookItemState();
  }
}

class BookItemState extends State<BookItem> {

  @override
  Widget build(BuildContext context) {
    return Container(
        child: InkWell(
            onLongPress: () =>
                showArticleMenu(context, widget.skey, widget.book),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => ArticlePage(
                            article: widget.book,
                          )));
            },
            child: Material(
                borderRadius: BorderRadius.circular(5.0),
                clipBehavior: Clip.antiAlias,
                elevation: 5.0,
                child: Hero(
                  tag: widget.book.title,
                  child: CachedNetworkImage( errorWidget: Image.asset(
                                      "assets/logo.jpg"
                                    ),
                      fit: BoxFit.cover,
                      imageUrl: widget.book.img,
                      placeholder: Container()),
                ))));
  }
}
