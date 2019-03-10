import 'dart:async';
import 'dart:math';
import 'package:background_audio/background_audio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:darulfikr/ui/audio/miniplayer.dart';
import 'package:darulfikr/ui/fragments/article_list.dart';
import 'package:darulfikr/ui/fragments/divider.dart';
import 'package:darulfikr/ui/fragments/horizontal_listview.dart';
import 'package:darulfikr/ui/fragments/slider.dart';
import 'package:darulfikr/ui/pages/articles_page.dart';
import 'package:darulfikr/ui/pages/books_page.dart';
import 'package:darulfikr/ui/pages/detail_page.dart';
import 'package:darulfikr/ui/pages/favorite_page.dart';
import 'package:darulfikr/ui/pages/search/search_page.dart';
import 'package:darulfikr/ui/pages/settings_page.dart';
import 'package:darulfikr/ui/pages/videos_page.dart';
import 'package:darulfikr/utils/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:darulfikr/bloc/article_bloc/article_bloc.dart';
import 'package:darulfikr/bloc/article_bloc/article_event.dart';
import 'package:darulfikr/bloc/article_bloc/article_state.dart';
import 'package:darulfikr/model/article.dart';
import 'package:darulfikr/ui/audio/audio_category.dart';
import 'package:darulfikr/utils/other.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _sKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  List<Map<dynamic, dynamic>> listCategory = List();
  @override
  void initState() {
    listCategory = [
      {
        Icon(Icons.whatshot): MainPage(
          page: 15,
          category: 12,
        ),
        "title": "Даруль-Фикр"
      },
      {Icon(Icons.format_list_bulleted): ArticleCategory(), "title": "Статьи"},
      {
        Icon(Icons.ondemand_video): Videos(
          page: 100,
          category: 13,
        ),
        "title": "Видео"
      },
      {Icon(Icons.headset): AudioCategoryView(), "title": "Аудио"},
      {
        Icon(Icons.book): Books(
          page: 100,
          category: 49,
        ),
        "title": "Книги"
      },
      {Icon(Icons.bookmark): Favorite(), "title": "Избранное"},
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Settings()))),
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Search())))
        ],
        title: Text(
          listCategory[_currentIndex]["title"],
        ),
      ),
      drawer: InkWell(
        onTap: () {},
        child: Drawer(
          child: Container(
            color: Theme.of(context).cardColor,
            child: ListView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Image.asset("assets/logo.jpg"),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                ),
                Column(
                  children: listCategory
                      .map<Widget>((category) => ListTile(
                          selected:
                              _currentIndex == listCategory.indexOf(category),
                          title: Text(
                            category['title'],
                            textScaleFactor: 1.15,
                          ),
                          leading: category.keys.first,
                          onTap: () {
                            setState(() =>
                                _currentIndex = listCategory.indexOf(category));
                            Navigator.pop(context);
                          }))
                      .toList(),
                ),
                Material(
                  elevation: 0.5,
                  child: BackgroundAudio.song != null
                      ? MiniPlayer(
                          scaffoldKey: _sKey,
                        )
                      : Container(
                          height: 0,
                          width: 0,
                        ),
                ),
                SizedBox(
                  height: 5,
                ),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: SocialMedia(),
                // ),
              ],
            ),
          ),
        ),
      ),
      body: listCategory[_currentIndex].values.first,
    );
  }
}

class MainPage extends StatefulWidget {
  final int page;
  final int category;

  const MainPage({Key key, this.page, this.category}) : super(key: key);
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _scrollController = ScrollController();
  var random = Random().nextInt(10).ceil();
  var sectionRandom = Random().nextInt(sections.reversed.length).ceil();
  ArticleBloc _articleBloc;
  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  final _scrollThreshold = 200.0;

  var _refreshCompleter;
  _MainPageState() {
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

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _articleBloc.dispatch(Fetch());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        body: RefreshIndicator(
            onRefresh: () {
              _articleBloc.dispatch(Refresh());
              return _refreshCompleter.future;
            },
            child: BlocBuilder(
              bloc: _articleBloc,
              builder: (c, state) {
                if (state is ArticleUninitialized) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                      ),
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
                    padding: EdgeInsets.all(3),
                    itemBuilder: (BuildContext context, int index) {
                      return index >= state.articles.length
                          ? BottomLoader()
                          : (index % 5 == 0)
                              ? ArticleCard(
                                  sKey: _key, post: state.articles[index])
                              : (index == 3)
                                  ? DivideHeader(
                                      headerText: "Видео",
                                      widget: ArticleSlider(
                                        sKey: _key,
                                        category: 13,
                                      ))
                                  : (index == 8)
                                      ? DivideHeader(
                                          widget: HorizontalList(
                                            sKey: _key,
                                            category: 49,
                                          ),
                                          headerText: "Книги",
                                        )
                                      : (index == random)
                                          ? DivideHeader(
                                              widget: ArticleSlider(
                                                  sKey: _key,
                                                  category: sections[
                                                          sectionRandom.toInt()]
                                                      .values
                                                      .first),
                                              headerText: sections[
                                                      sectionRandom.toInt()]
                                                  .keys
                                                  .first,
                                            )
                                          : (index.remainder(13) == 0)
                                              ? ArticleSlider(
                                                  sKey: _key,
                                                  category: sections[Random()
                                                          .nextInt(
                                                              sections.length)
                                                          .toInt()]
                                                      .values
                                                      .first)
                                              : (index % 3 == 0)
                                                  ? firstHomeArticle(
                                                      state.articles[index],
                                                      _key)
                                                  : homeArticle(
                                                      state.articles[index],
                                                      _key);
                    },
                    itemCount: state.hasReachedMax
                        ? state.articles.length
                        : state.articles.length + 1,
                    controller: _scrollController,
                  );
                }
              },
            )));
  }

  Widget booksHomeView(List<Article> list) {
    return Padding(
        padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
        child: Material(
            elevation: 3.0,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    "Книги",
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
              ],
            )));
  }

  Widget firstHomeArticle(Article article, GlobalKey key) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: InkWell(
        onLongPress: () => showArticleMenu(context, key, article),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (c) => ArticlePage(
                      article: article,
                    ))),
        child: Material(
          elevation: 3.0,
          child: Column(
            verticalDirection: VerticalDirection.down,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  article.title,
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  !article.about.contains("[...]")
                      ? article.about
                              .replaceAll("<p>", "")
                              .replaceAll("</p>", "")
                              .replaceAll("[", "")
                              .replaceAll("]", "") ??
                          'About'
                      : "Видео",
                  maxLines: 11,
                  textScaleFactor: 0.9,
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .copyWith(fontSize: 18.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  parseDateAgo(article.date),
                  style: Theme.of(context).textTheme.caption,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget homeArticle(Article article, GlobalKey key) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: InkWell(
        onLongPress: () => showArticleMenu(context, key, article),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (c) => ArticlePage(
                      article: article,
                    ))),
        child: Material(
          elevation: 3.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[buildText(article), buildImage(article)],
          ),
        ),
      ),
    );
  }

  buildText(Article article) {
    return Expanded(
        child: Container(
            padding: EdgeInsets.all(8.0),
            child: (Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    article.title,
                    style: Theme.of(context)
                        .textTheme
                        .body1
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    !article.about.contains("[...]")
                        ? article.about
                                .replaceAll("<p>", "")
                                .replaceAll("</p>", "")
                                .replaceAll("[", "")
                                .replaceAll("]", "") ??
                            'About'
                        : "Видео",
                    maxLines: 6,
                    textScaleFactor: 0.9,
                    style: Theme.of(context)
                        .textTheme
                        .body1
                        .copyWith(fontSize: 15.0),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    parseDateAgo(article.date),
                    style: Theme.of(context).textTheme.caption,
                  )
                ]))));
  }

  buildImage(Article article) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(8.0),
          width: 100,
          height: 100,
          child: Material(
            elevation: 7,
            child: Hero(
              tag: article.title,
              child: CachedNetworkImage( errorWidget: Image.asset(
                                      "assets/logo.jpg"
                                    ),
                  imageUrl: article.img,
                  placeholder: Container(),
                  fit: BoxFit.cover),
            ),
          ),
        ),
        article.video.isNotEmpty
            ? Icon(Icons.play_arrow, size: 50.0, color: Colors.grey.shade500)
            : Container()
      ],
    );
  }
}
