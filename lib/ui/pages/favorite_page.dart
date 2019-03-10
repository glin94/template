import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:darulfikr/ui/fragments/article_list.dart';
import 'package:darulfikr/ui/fragments/slider.dart';
import 'package:darulfikr/utils/constants.dart';
import 'package:darulfikr/utils/parallax/intropage_view.dart';
import 'package:flutter/material.dart';
import 'package:darulfikr/model/article.dart';
import 'package:darulfikr/resources/repository.dart';

class Favorite extends StatefulWidget {
  _FavoriteState createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  GlobalKey<ScaffoldState> _skey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    _tabController =
        new TabController(vsync: this, length: favoriteSections.length);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: favoriteSections.length,
        child: Scaffold(
            key: _skey,
            appBar: new PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: new SafeArea(
                child: Column(
                  children: <Widget>[
                    new TabBar(
                      isScrollable: true,
                      unselectedLabelColor: Colors.grey,
                      labelColor: Colors.white,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: new BubbleTabIndicator(
                        indicatorHeight: 35.0,
                        indicatorColor: Theme.of(context).accentColor,
                        tabBarIndicatorSize: TabBarIndicatorSize.tab,
                      ),
                      tabs: favoriteSections
                          .map<Tab>((f) => Tab(
                                text: f.keys.first,
                              ))
                          .toList(),
                      controller: _tabController,
                    ),
                  ],
                ), //категории
              ),
            ),
            body: new TabBarView(
                controller: _tabController,
                children: favoriteSections
                    .map<Widget>((f) => FavoriteSection(
                          category: f.values.first,
                        ))
                    .toList())));
  }
}

class FavoriteSection extends StatelessWidget {
  final String category;
  const FavoriteSection({Key key, this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<List<Article>>(
        future: Repository.get().getFavoriteArticlesFromDB(category),
        builder: (BuildContext context, AsyncSnapshot<List<Article>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('Press button to start.');
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(
                  child: CircularProgressIndicator(
                strokeWidth: 1.5,
              ));
            case ConnectionState.done:
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              if (snapshot.data.isNotEmpty) {
                switch (category) {
                  case "":
                    return ArticleListView(listArticle: snapshot.data);
                    break;
                  case "video":
                    return CardList(cardList: snapshot.data);
                  case "book":
                    return IntroPageView(snapshot.data);
                  default:
                    return Container();
                }
              } else
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.bookmark_border,
                        size: 100,
                        color: Colors.grey.shade700,
                      ),
                      Text("Пока статей нет"),
                    ],
                  ),
                );
          }
        },
      ),
    );
  }
}
