import 'package:darulfikr/utils/constants.dart';
import 'package:darulfikr/utils/other.dart';
import 'package:flutter/material.dart';

class SocialMedia extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
          child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: social.map<Widget>((item) => IconButton(
              icon: item.keys.first,
              onPressed: () => launchURL(item.values.first),
            )).toList(),
    ),
        ));
  }
}
