import 'package:cached_network_image/cached_network_image.dart';
import 'package:darulfikr/model/article.dart';
import 'package:darulfikr/utils/parallax/pagetransformer.dart';
import 'package:flutter/material.dart';

import 'package:meta/meta.dart';

//Parallax
class IntroPageItem extends StatelessWidget {
  IntroPageItem(
    this.article,
    this.pageVisibility,
  );

  final Article article;
  final PageVisibility pageVisibility;

  Widget _applyTextEffects({
    @required double translationFactor,
    @required Widget child,
  }) {
    final double xTranslation = pageVisibility.pagePosition * translationFactor;

    return Opacity(
      opacity: pageVisibility.visibleFraction,
      child: Transform(
        alignment: FractionalOffset.topLeft,
        transform: Matrix4.translationValues(
          xTranslation,
          0.0,
          0.0,
        ),
        child: child,
      ),
    );
  }

  _buildTextContainer(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var categoryText = _applyTextEffects(
      translationFactor: 300.0,
      child: Text(
        article.authors.first ?? "Authors",
        style: textTheme.caption.copyWith(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          fontSize: 14.0,
        ),
        textAlign: TextAlign.center,
      ),
    );

    var titleText = _applyTextEffects(
      translationFactor: 200.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Text(
          article.title ?? "Title",
          style: textTheme.title
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );

    return Positioned(
      bottom: 56.0,
      left: 32.0,
      right: 32.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          categoryText,
          titleText,
        ],
      ),
    );
  }

  Widget _getImageNetwork(url) {
    return ClipRRect(
        borderRadius: new BorderRadius.circular(8.0),
        child: CachedNetworkImage( errorWidget: Image.asset(
                                      "assets/logo.jpg"
                                    ),
          placeholder: Container(),
          imageUrl: url,
          fit: BoxFit.cover,
          alignment: FractionalOffset(
            0.5 + (pageVisibility.pagePosition / 3),
            0.5,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 8.0,
        ),
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(8.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(tag: article.title, child: _getImageNetwork(article.img)),
              _getOverlayGradient(),
              _buildTextContainer(context),
            ],
          ),
        ));
  }

  static _getOverlayGradient() {
    return ClipRRect(
      borderRadius: new BorderRadius.only(
          bottomLeft: Radius.circular(8.0), bottomRight: Radius.circular(8.0)),
      child: new DecoratedBox(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            begin: FractionalOffset.bottomCenter,
            end: FractionalOffset.topCenter,
            colors: [
              const Color(0xFF000000),
              const Color(0x00000000),
            ],
          ),
        ),
      ),
    );
  }
}
