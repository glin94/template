import 'package:darulfikr/ui/fragments/article_list.dart';
import 'package:darulfikr/ui/fragments/divider.dart';
import 'package:darulfikr/ui/related_posts.dart';
import 'package:darulfikr/utils/constants.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:darulfikr/model/article.dart';
import 'package:darulfikr/resources/repository.dart';
import 'package:darulfikr/utils/other.dart';
import 'package:flutter_html_view/flutter_html_view.dart';

class ArticlePage extends StatefulWidget {
  final Article article;
  const ArticlePage({Key key, this.article}) : super(key: key);
  @override
  _ArticlePageState createState() => _ArticlePageState(this.article);
}

const kExpandedHeight = 300.0;

class _ArticlePageState extends State<ArticlePage> {
  Article article;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  double _fontSize;
  bool show = false;
  PersistentBottomSheetController controller;
  bool _isOpen = false;
  String _fontFamily;
  List<DropdownMenuItem<String>> _dropDownMenuItems;

  _ArticlePageState(this.article);
  @override
  void initState() {
    super.initState();
    Repository.get().updateArticle(article);

    SystemChrome.setEnabledSystemUIOverlays([]); // полный экран
    _initReadSettings(); // инит настроек чтения
    _dropDownMenuItems = getDropDownMenuItems(); //инит меню шрифта
    shareTimer(article, scaffoldKey,
        context); // таймер для того, чтобы поделиться статьёй
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton:
            article.book.isNotEmpty || article.audio.isNotEmpty
                ? FloatingActionButton(
                    child: Icon(
                      Icons.file_download,
                    ),
                    onPressed: () => downloadBook(article, scaffoldKey))
                : Container(),
        key: scaffoldKey,
        body: builder());
  }

//виджет для всей страницы
  Widget builder() =>
      CustomScrollView(physics: BouncingScrollPhysics(), slivers: <Widget>[
        buildSliverAppBar(),
        SliverList(
          delegate: SliverChildListDelegate(<Widget>[
            buildHeader(),
            buildImage(),
            buildAuthors(),
            buildDate(),
            buildContent(),
            buildTags(),
            DivideHeader(
              headerText:
                  article.relatedPosts.isNotEmpty ? "Похожие материалы" : null,
              widget: RelatedPostsView(
                sKey: scaffoldKey,
                link: article.relatedPosts,
              ),
            )
          ]),
        )
      ]);

  Widget buildSliverAppBar() {
    return SliverAppBar(
      centerTitle: true,
      floating: true,
      snap: true,
      title: Text(article.categories.first ?? "Статьи",
          style:
              Theme.of(context).textTheme.title.copyWith(color: Colors.white)),
      forceElevated: true,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.text_fields),
          onPressed: () =>
              _isOpen ? controller.close() : _showTextChangeDialog(),
        ),
        IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => showArticleMenu(context, scaffoldKey, article))
      ],
      titleSpacing: 0.0,
      elevation: 2.0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(Icons.arrow_back),
      ),
    );
  }

  Widget buildImage() {
    return Container(
      height: 350.0,
      child: Hero(
        tag: article.title,
        child: CachedNetworkImage(
          errorWidget: Image.asset("assets/logo.jpg"),
          placeholder: Container(),
          imageUrl: article.img != null
              ? article.img
              : "https://pp.userapi.com/c836735/v836735739/2903f/Jz-Y3GlUA6g.jpg",
          fit: article.img != null ? BoxFit.cover : BoxFit.contain,
        ),
      ),
    );
  }

  Widget buildAuthors() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: article.authors
            .map<Widget>(
              (f) => Text(f.trimLeft(),
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.title.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        fontFamily: _fontFamily,
                      )),
            )
            .toList(),
      ),
    );
  }

  Widget buildDate() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Text(
          parseDate(article.date).toUpperCase(),
          style:
              Theme.of(context).textTheme.subtitle.copyWith(color: Colors.grey),
        ),
      ),
    );
  }

  Widget buildHeader() => Padding(
      padding: EdgeInsets.all(14.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: new Text(
          article.title,
          semanticsLabel: article.authors.toString(),
          textScaleFactor: 1.8,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: _fontFamily,
          ),
        ),
      ));

  Widget buildContent() => GestureDetector(
      onTap: () {
        scaffoldKey.currentState.hideCurrentSnackBar();
        if (_isOpen) controller.close();
      },
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: DefaultTextStyle(
            style: Theme.of(context).textTheme.body1.copyWith(
                fontFamily: _fontFamily,
                height: 1.4,
                fontSize: _fontSize,
                fontWeight: FontWeight.w400),
            child: new HtmlView(
                data: article.content,
                padding: EdgeInsets.zero,
                onLaunchFail: (url) {
                  showFootnote(url, scaffoldKey, article, context);
                })),
      ));

  Widget buildTags() => article.tags[0] != ""
      ? Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Wrap(
                        spacing: 7.0,
                        children: article.tags
                            .map<Widget>((f) => ActionChip(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.padded,
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TagsPage(
                                              article: article, f: f))),
                                  label: Text(
                                    f.trimLeft(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  shape: StadiumBorder(
                                      side: BorderSide(
                                          color:
                                              Theme.of(context).accentColor)),
                                  labelStyle: TextStyle(
                                      color: Theme.of(context).accentColor),
                                  backgroundColor:
                                      Theme.of(context).accentColor,
                                ))
                            .toList()),
                  ),
                ),
              )
            ],
          ),
        )
      : Container();

// меню шрифта
  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String font in fonts) {
      items.add(new DropdownMenuItem(
          value: font,
          child: Padding(
            child: Text(font),
            padding: EdgeInsets.all(8.0),
          )));
    }
    return items;
  }

//настройки для чтения
  _initReadSettings() async {
    SharedPreferences textPrefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = (textPrefs.getDouble('fontsize') ?? 16.0);
      _fontFamily = (textPrefs.getString('fontfamily') ?? fonts[0]);
    });
  }

  //меню настройки чтения
  _showTextChangeDialog() {
    scaffoldKey.currentState.hideCurrentSnackBar();
    controller =
        scaffoldKey.currentState.showBottomSheet<Null>((BuildContext context) {
      return new Container(
          padding: EdgeInsets.all(10.0),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "A",
                          style: TextStyle(fontSize: 15.0),
                        ),
                        Icon(
                          Icons.remove,
                          size: 15.0,
                        ),
                      ],
                    ),
                    onPressed: _fontSize != 11
                        ? () async {
                            SharedPreferences textPrefs =
                                await SharedPreferences.getInstance();
                            setState(() {
                              _fontSize--;
                              textPrefs.setDouble('fontsize', _fontSize);
                              controller.setState(() {});
                            });
                          }
                        : null,
                  ),
                  FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          "A",
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                        Icon(
                          Icons.add,
                          size: 20.0,
                        ),
                      ],
                    ),
                    onPressed: _fontSize != 20
                        ? () async {
                            SharedPreferences textPrefs =
                                await SharedPreferences.getInstance();
                            setState(() {
                              _fontSize++;
                              textPrefs.setDouble('fontsize', _fontSize);
                              controller.setState(() {});
                            });
                          }
                        : null,
                  ),
                  RaisedButton(
                    onPressed: () {
                      DynamicTheme.of(context).brightness == Brightness.dark
                          ? DynamicTheme.of(context)
                              .setBrightness(Brightness.light)
                          : DynamicTheme.of(context)
                              .setBrightness(Brightness.dark);
                      controller.setState(() {});
                    },
                    color:
                        DynamicTheme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black54,
                    child: Text(
                        DynamicTheme.of(context).brightness == Brightness.dark
                            ? "День"
                            : "Ночь",
                        style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.text_format,
                  ),
                  DropdownButton(
                    elevation: 16,
                    value: _fontFamily,
                    items: _dropDownMenuItems,
                    onChanged: (String selected) async {
                      SharedPreferences textPrefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        textPrefs.setString('fontfamily', selected);
                        controller.setState(() {
                          _fontFamily = selected;
                        });
                      });
                    },
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  RaisedButton(
                      color: Colors.white,
                      onPressed: () async {
                        SharedPreferences textPrefs =
                            await SharedPreferences.getInstance();
                        setState(() {
                          textPrefs.setString('fontfamily', "PT Sans");
                          textPrefs.setDouble('fontsize', 16.0);
                          _initReadSettings();
                          controller.setState(() {});
                        });
                      },
                      child: Text(
                        "По умолчанию",
                        style: TextStyle(fontSize: 15.0, color: Colors.black),
                      ))
                ],
              ),
            ],
          ));
    });
    controller.closed.then((_) {
      setState(() => _isOpen = false);
    });

    setState(() {
      _isOpen = true;
    });
  }
}

class TagsPage extends StatelessWidget {
  const TagsPage({
    Key key,
    @required this.article,
    this.f,
  }) : super(key: key);

  final Article article;
  final String f;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.close,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            f.trimLeft(),
          )),
      body: FutureBuilder(
        future: Repository.get().getArticlesbyTags(
            int.parse(article.tagsId[article.tags.indexOf(f)].trimLeft())),
        builder: (BuildContext context, AsyncSnapshot<List<Article>> snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (c, i) {
                    return ArticleWidget(
                      article: snapshot.data[i],
                    );
                  },
                  itemCount: snapshot.data.length,
                )
              : Center(
                  child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                ));
        },
      ),
    );
  }
}
