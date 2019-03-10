import 'package:cached_network_image/cached_network_image.dart';
import 'package:darulfikr/bloc/article_bloc/article_bloc.dart';
import 'package:darulfikr/bloc/article_bloc/article_event.dart';
import 'package:darulfikr/bloc/article_bloc/article_state.dart';
import 'package:darulfikr/model/article.dart';
import 'package:darulfikr/ui/pages/detail_page.dart';
import 'package:darulfikr/ui/pages/videos_page.dart';
import 'package:darulfikr/ui/related_posts.dart';
import 'package:darulfikr/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:darulfikr/utils/other.dart';

class ArticleSlider extends StatefulWidget {
  final int category;
  final GlobalKey<ScaffoldState> sKey;
  const ArticleSlider({Key key, this.category, this.sKey}) : super(key: key);
  _ArticleSliderState createState() => _ArticleSliderState();
}

class _ArticleSliderState extends State<ArticleSlider> {
  ArticleBloc _articleBloc;

  @override
  void initState() {
    _articleBloc = ArticleBloc(
      httpClient: http.Client(),
      category: widget.category,
      page: 99,
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
          return Container();
        }
        if (state is ArticleLoaded) {
          if (state.articles.isEmpty) {
            return Center(
              child: Text('Произошла неизвестная ошибка'),
            );
          }
          return Carousel(
            list: state.articles,
            context: context,
            sKey: widget.sKey,
          );
        }
      },
    );
  }
}

class CardList extends StatelessWidget {
  final List<Article> cardList;
  final GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  CardList({Key key, this.cardList}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      body: Container(
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: cardList.length,
            itemBuilder: (c, i) => ArticleCard(sKey: sKey, post: cardList[i])),
      ),
    );
  }
}

class ArticleCard extends StatefulWidget {
  final Article post;
  final GlobalKey<ScaffoldState> sKey;
  const ArticleCard({Key key, this.post, this.sKey}) : super(key: key);
  _ArticleCardState createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard> {
  @override
  Widget build(BuildContext context) {
    return new Container(
        margin: new EdgeInsets.all(5.0),
        child: new ClipRRect(
            borderRadius: new BorderRadius.all(new Radius.circular(5.0)),
            child: new Stack(
              children: <Widget>[
                new InkWell(
                    onLongPress: () =>
                        showArticleMenu(context, widget.sKey, widget.post),
                    onTap: () => widget.post.video.isEmpty
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ArticlePage(article: widget.post)))
                        : playYoutubeVideoByUrl(widget.post.video),
                    child: Hero(
                        tag: widget.post.title,
                        child: CachedNetworkImage(
                          errorWidget: Image.asset("assets/logo.jpg"),
                          imageUrl:
                              widget.post.img != null ? widget.post.img : logo,
                          fit: BoxFit.cover,
                          width: 1000.0,
                          placeholder: Container(),
                        ))),
                new Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: new Container(
                        decoration: new BoxDecoration(
                            gradient: new LinearGradient(
                          colors: [
                            Color.fromARGB(200, 0, 0, 0),
                            Color.fromARGB(0, 0, 0, 0)
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        )),
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: new Text(
                          widget.post.title,
                          maxLines: 2,
                          style: new TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold),
                        ))),
                buildPlayIcon(widget.post),
              ],
            )));
  }

  Widget buildPlayIcon(Article article) {
    return article.video.isNotEmpty
        ? Positioned(
            right: 5,
            bottom: 5,
            child: Stack(alignment: Alignment.center, children: <Widget>[
              Container(
                height: 20,
                width: 20,
                color: Colors.black,
              ),
              Icon(
                Icons.play_arrow,
                color: Colors.grey,
                size: 20,
              ),
            ]),
          )
        : Container();
  }
}
