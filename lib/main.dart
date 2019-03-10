import 'package:bloc/bloc.dart';
import 'package:darulfikr/ui/fragments/splashscreen.dart';
import 'package:darulfikr/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:darulfikr/bloc/article_bloc/simple_bloc_delegate.dart';
import 'package:darulfikr/utils/other.dart';

void main() {
  initTimeLang();
  BlocSupervisor().delegate = SimpleBlocDelegate();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new DynamicTheme(
        defaultBrightness: Brightness.dark,
        data: (brightness) => new ThemeData(
            primarySwatch: accent,
            accentColor: accent,
            brightness: brightness,
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            }),
            fontFamily: fonts[0]),
        themedWidgetBuilder: (context, theme) {
          return new MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: SplashScreen(),
          );
        });
  }
}
