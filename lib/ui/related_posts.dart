import 'package:carousel_slider/carousel_slider.dart';
import 'package:darulfikr/model/article.dart';
import 'package:darulfikr/resources/repository.dart';
import 'package:darulfikr/ui/fragments/slider.dart';
import 'package:flutter/material.dart';

class RelatedPostsView extends StatelessWidget {
  final String link;
  final GlobalKey<ScaffoldState> sKey;
  const RelatedPostsView({Key key, this.link, this.sKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder(
      future: Repository.get().getRelatedPosts(link),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData)
          return new Carousel(
              sKey: sKey, list: snapshot.data, context: context);
        else if (link.isEmpty)
          return Container();
        else
          return Container(
            child: Center(
                heightFactor: 5.5,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                )),
          );
      },
    ));
  }
}

class Carousel extends StatelessWidget {
  const Carousel({
    Key key,
    @required this.list,
    @required this.context,
    this.sKey,
  }) : super(key: key);

  final List<Article> list;
  final BuildContext context;
  final GlobalKey<ScaffoldState> sKey;
  @override
  Widget build(BuildContext context) => new Padding(
      padding: new EdgeInsets.symmetric(vertical: 15.0),
      child: new CarouselSlider(
        items: list.map((post) {
          return ArticleCard(
            post: post,
            sKey: sKey,
          );
        }).toList(),
        autoPlay: true,
        viewportFraction: 0.9,
        aspectRatio: 2.0,
        autoPlayCurve: Curves.easeInOut,
        reverse: false,
        interval: Duration(seconds: 7),
      ));
}
