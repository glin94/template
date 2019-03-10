import 'package:flutter/material.dart';

class DivideHeader extends StatelessWidget {
  const DivideHeader({
    Key key,
    @required this.widget,
    this.headerText,
  }) : super(key: key);

  final Widget widget;
  final String headerText;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          headerText != null
              ? AppBar(
                  automaticallyImplyLeading: false,
                  title: Text(headerText),
                )
              : Container(),
          widget
        ],
      ),
    );
  }
}
