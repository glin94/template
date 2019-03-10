import 'dart:async';
import 'package:darulfikr/ui/pages/home_page.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    new Timer(new Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context, new MyCustomRoute(builder: (context) => HomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Hero(
                          tag: "logo",
                          child: Image.asset(
                            'assets/logo.jpg',
                            width: 300,
                            height: 300,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Text(
                        "Даруль-Фикр.Ру",
                        style: Theme.of(context)
                            .textTheme
                            .title
                            .copyWith(color: Colors.black, fontSize: 30.0),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (settings.isInitialRoute) return child;

    return new FadeTransition(opacity: animation, child: child);
  }
}
