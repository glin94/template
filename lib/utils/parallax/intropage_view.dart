import 'package:darulfikr/model/article.dart';
import 'package:darulfikr/ui/pages/detail_page.dart';
import 'package:darulfikr/utils/other.dart';
import 'package:darulfikr/utils/parallax/intropage_item.dart';
import 'package:darulfikr/utils/parallax/pagetransformer.dart';
import 'package:flutter/material.dart';

class IntroPageView extends StatefulWidget {
  final List<Article> articles;
  IntroPageView(this.articles);
  @override
  IntroPageViewState createState() {
    return new IntroPageViewState(this.articles);
  }
}

class IntroPageViewState extends State<IntroPageView> {
  final List<Article> articles;
  GlobalKey<ScaffoldState> _skey = GlobalKey<ScaffoldState>();
  IntroPageViewState(this.articles);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _skey,
        body: Center(
          child: articles.isNotEmpty
              ? SizedBox.fromSize(
                  size: const Size.fromHeight(500.0),
                  child: PageTransformer(
                    pageViewBuilder: (context, visibilityResolver) {
                      return PageView.builder(
                        controller: PageController(viewportFraction: 0.85),
                        itemCount: articles.length,
                        itemBuilder: (context, index) {
                          Article article = articles[index];
                          final pageVisibility =
                              visibilityResolver.resolvePageVisibility(index);
                          return GestureDetector(
                            onLongPress: () =>
                                showArticleMenu(context, _skey, article),
                            onTap: () => article.video.isEmpty
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ArticlePage(article: article)))
                                : playYoutubeVideoByUrl(article.video),
                            child: IntroPageItem(
                              article,
                              pageVisibility,
                            ),
                          );
                        },
                      );
                    },
                  ))
              : Center(
                  child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                )),
        ));
  }
}
