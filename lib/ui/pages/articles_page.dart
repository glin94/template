import 'package:darulfikr/ui/fragments/article_list.dart';
import 'package:darulfikr/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';

class ArticleCategory extends StatefulWidget {
  _ArticleCategoryState createState() => _ArticleCategoryState();
}

class _ArticleCategoryState extends State<ArticleCategory>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  _ArticleCategoryState();

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: sections.length);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: sections.length,
        child: Scaffold(
            appBar: new PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight + 50),
              child: new SafeArea(
                child: new TabBar(
                  isScrollable: true,
                  unselectedLabelColor: Colors.grey,
                  labelColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: new BubbleTabIndicator(
                    indicatorHeight: 35.0,
                    indicatorColor: Theme.of(context).accentColor,
                    tabBarIndicatorSize: TabBarIndicatorSize.tab,
                  ),
                  tabs: sections
                      .map<Tab>((f) => Tab(
                            text: f.keys.first,
                          ))
                      .toList(),
                  controller: _tabController,
                ), //категории
              ),
            ),
            body: new TabBarView(
                controller: _tabController,
                children: sections
                    .map<Widget>((f) => ArticleList(
                          category: f.values.first,
                          page: 25,
                        ))
                    .toList())));
  }
}
